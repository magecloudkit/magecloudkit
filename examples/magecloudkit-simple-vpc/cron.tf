# ---------------------------------------------------------------------------------------------------------------------
# MAGENTO CRON TASK DEFINITION
#
# Create a ECS task definition for running the crons.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ecs_task_definition" "cron_task_definition" {
  task_definition = "${aws_ecs_task_definition.app_service_task_definition.family}"
  depends_on      = ["aws_ecs_task_definition.app_service_task_definition"]
}

resource "aws_ecs_task_definition" "cron_task_definition" {
  family                = "${var.project_name}-cron"
  container_definitions = "${data.template_file.ecs_cron_task_container_definitions.rendered}"

  volume = {
    name      = "media"
    host_path = "/mnt/media/magento"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE ECS CONTAINER DEFINITIONS FOR THE CRON TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ecs_cron_task_container_definitions" {
  template = "${file("./task-definitions/cron.json")}"

  vars {
    environment                   = "${var.environment}"
    app_mage_mode                 = "production"
    magento_image                 = "magecloudkit/magento2:latest"
    php_memory_limit              = "768M"
    cloudwatch_logs_group         = "${module.cron_logs.log_group_id}"
    cloudwatch_logs_region        = "${var.aws_region}"
    cloudwatch_logs_stream_prefix = "cron"
    mysql_host                    = "${var.env_mysql_host}"
    mysql_database                = "${var.env_mysql_database}"
    mysql_user                    = "${var.env_mysql_user}"
    mysql_password                = "${var.env_mysql_password}"
    redis_cache_host              = "${aws_route53_record.redis_cache.fqdn}"
    redis_session_host            = "${aws_route53_record.redis_session.fqdn}"
    mage_table_prefix             = "${var.env_mage_table_prefix}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE THE CRON SCHEDULE AND CLOUDWATCH EVENT TARGETS
#
# We run the Magento cron and indexer every 5 minutes on the App Cluster.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "cron_schedule" {
  name                = "${terraform.workspace}-cron-schedule"
  description         = "magento cron schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "magento_cron" {
  target_id = "run-mage-cron-every-five-minutes"
  arn       = "${module.app_cluster.cluster_arn}"
  rule      = "${aws_cloudwatch_event_rule.cron_schedule.name}"
  role_arn  = "${aws_iam_role.ecs_events.arn}"

  ecs_target = {
    task_count          = 1
    task_definition_arn = "${aws_ecs_task_definition.cron_task_definition.arn}"
  }

  input = <<EOF
{
  "containerOverrides": [
    {
      "name": "cron",
      "command": ["php", "/var/www/html/bin/magento", "cron:run"]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "magento_indexer" {
  target_id = "run-mage-indexer-every-five-minutes"
  arn       = "${module.app_cluster.cluster_arn}"
  rule      = "${aws_cloudwatch_event_rule.cron_schedule.name}"
  role_arn  = "${aws_iam_role.ecs_events.arn}"

  ecs_target = {
    task_count          = 1
    task_definition_arn = "${aws_ecs_task_definition.cron_task_definition.arn}"
  }

  input = <<EOF
{
  "containerOverrides": [
    {
      "name": "cron",
      "command": ["php", "/var/www/html/bin/magento", "indexer:reindex"]
    }
  ]
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE THE NECESSARY IAM ROLES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_events" {
  name = "ecs_events"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = "${aws_iam_role.ecs_events.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(aws_ecs_task_definition.cron_task_definition.arn, "/:\\d+$/", ":*")}"
        }
    ]
}
EOF
}
