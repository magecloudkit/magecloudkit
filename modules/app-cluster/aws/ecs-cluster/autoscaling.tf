resource "aws_autoscaling_policy" "policy" {
  count                  = "${var.enable_autoscaling ? length(var.autoscaling_properties) : 0}"
  name                   = "${var.cluster_name}-${lookup(var.autoscaling_properties[count.index], "type")}-${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],1)}"
  scaling_adjustment     = "${lookup(var.autoscaling_properties[count.index], "scaling_adjustment")}"
  adjustment_type        = "${lookup(var.autoscaling_properties[count.index], "adjustment_type")}"
  cooldown               = "${lookup(var.autoscaling_properties[count.index], "cooldown")}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling_group.name}"
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count               = "${var.enable_autoscaling ? length(var.autoscaling_properties) : 0}"
  alarm_name          = "${var.cluster_name}-${lookup(var.autoscaling_properties[count.index], "type")}-${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],1)}"
  comparison_operator = "${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],0)}"
  evaluation_periods  = "${lookup(var.autoscaling_properties[count.index], "evaluation_periods")}"
  metric_name         = "${lookup(var.autoscaling_properties[count.index], "type")}"
  namespace           = "AWS/ECS"
  period              = "${lookup(var.autoscaling_properties[count.index], "observation_period")}"
  statistic           = "${lookup(var.autoscaling_properties[count.index], "statistic")}"
  threshold           = "${lookup(var.autoscaling_properties[count.index], "threshold")}"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.policy.*.arn[count.index]}"]
}

resource "aws_sns_topic" "asg_lifecycle" {
  count = "${var.enable_autoscaling ? 1 : 0}"
  name  = "${var.cluster_name}-asg-lifecycle"
}

resource "aws_autoscaling_notification" "scale_notifications" {
  count = "${var.enable_autoscaling ? 1 : 0}"

  group_names = [
    "${aws_autoscaling_group.autoscaling_group.name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = "${aws_sns_topic.asg_lifecycle.arn}"
}

resource "aws_autoscaling_lifecycle_hook" "scale_hook" {
  count                   = "${var.enable_autoscaling ? 1 : 0}"
  name                    = "${var.cluster_name}-scale-hook"
  autoscaling_group_name  = "${aws_autoscaling_group.autoscaling_group.name}"
  default_result          = "ABANDON"
  heartbeat_timeout       = 900
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = "${aws_sns_topic.asg_lifecycle.arn}"
  role_arn                = "${aws_iam_role.asg_publish_to_sns.arn}"
}

resource "aws_iam_role" "asg_publish_to_sns" {
  count = "${var.enable_autoscaling ? 1 : 0}"
  name  = "${var.cluster_name}-asg-publish-to-sns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ {
    "Sid": "",
    "Effect": "Allow",
    "Principal": {
      "Service": "autoscaling.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  } ]
}
EOF
}

data "template_file" "asg_publish_to_sns" {
  count = "${var.enable_autoscaling ? 1 : 0}"

  vars {
    topic_arn = "${aws_sns_topic.asg_lifecycle.arn}"
  }

  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "$${topic_arn}",
      "Action": [
        "sns:Publish"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "asg_publish_to_sns" {
  count  = "${var.enable_autoscaling ? 1 : 0}"
  name   = "${var.cluster_name}-asg-publish-to-sns"
  role   = "${aws_iam_role.asg_publish_to_sns.name}"
  policy = "${data.template_file.asg_publish_to_sns.rendered}"
}

resource "aws_lambda_permission" "drain_lambda" {
  count         = "${var.enable_autoscaling ? 1 : 0}"
  statement_id  = "AllowExecutionFromSNS-${var.cluster_name}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.ecs_instance_draining_lambda_function_arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.asg_lifecycle.arn}"
}

resource "aws_sns_topic_subscription" "lambda" {
  count     = "${var.enable_autoscaling ? 1 : 0}"
  topic_arn = "${aws_sns_topic.asg_lifecycle.arn}"
  protocol  = "lambda"
  endpoint  = "${var.ecs_instance_draining_lambda_function_arn}"
}
