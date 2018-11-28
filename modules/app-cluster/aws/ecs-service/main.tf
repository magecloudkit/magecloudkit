# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE LOCAL VARIABLES SPECIFIC TO THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  cluster_plus_service_name = "${var.cluster_name}-${var.name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AWS ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name    = "${var.name}"
  cluster = "${var.cluster_arn}"

  # check the data provider so we don't deploy an old version of the container when re-running terraform
  desired_count                      = "${var.desired_task_count}"
  task_definition                    = "${var.task_definition}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"

  # required so that the ECS agent can talk to the load balancer
  iam_role = "${var.ecs_service_iam_role_arn}"

  load_balancer = {
    target_group_arn = "${var.target_group_arn}"

    # this value comes from the container definitions
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
  }

  # let ECS determine how to place containers
  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }

  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }

  # Ignore external changes from Autoscaling
  lifecycle {
    #ignore_changes = ["desired_count"]
    ignore_changes = ["desired_count", "task_definition", "revision"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AUTOSCALING RESOURCES
#
# This is only applicable if Autoscaling is enabled.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_appautoscaling_target" "target" {
  count              = "${var.enable_autoscaling}"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"
}

resource "aws_appautoscaling_policy" "policy" {
  count = "${(var.enable_autoscaling ? 1 : 0 ) * length(var.autoscaling_properties) }"

  name               = "${local.cluster_plus_service_name}-${lookup(var.autoscaling_properties[count.index], "type")}-${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],1)}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.name}"

  step_scaling_policy_configuration {
    adjustment_type         = "${lookup(var.autoscaling_properties[count.index], "adjustment_type")}"
    cooldown                = "${lookup(var.autoscaling_properties[count.index], "cooldown")}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = "${lookup(var.autoscaling_properties[count.index], "scaling_adjustment")}"
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count = "${(var.enable_autoscaling ? 1 : 0 ) * length(var.autoscaling_properties) }"

  alarm_name = "${local.cluster_plus_service_name}-${lookup(var.autoscaling_properties[count.index], "type")}-${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],1)}"

  comparison_operator = "${element(var.autoscaling_direction[lookup(var.autoscaling_properties[count.index], "direction")],0)}"

  evaluation_periods = "${lookup(var.autoscaling_properties[count.index], "evaluation_periods")}"
  metric_name        = "${lookup(var.autoscaling_properties[count.index], "type")}"
  namespace          = "AWS/ECS"
  period             = "${lookup(var.autoscaling_properties[count.index], "observation_period")}"
  statistic          = "${lookup(var.autoscaling_properties[count.index], "statistic")}"
  threshold          = "${lookup(var.autoscaling_properties[count.index], "threshold")}"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.policy.*.arn[count.index]}"]

  depends_on = ["aws_appautoscaling_target.target"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name = "${var.cluster_name}-${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
