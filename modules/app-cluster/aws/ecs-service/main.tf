# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AWS ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name    = "${var.name}"
  cluster = "${var.cluster_arn}"

  // check the data provider so we don't deploy an old version of the container when re-running terraform
  desired_count                      = "${var.desired_task_count}"
  task_definition                    = "${var.task_definition}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"

  #security_groups                    = ["${var.allowed_security_group_ids}"]

  // Required so that the ECS agent can talk to the load balancer
  iam_role = "${var.ecs_service_iam_role_arn}"
  load_balancer = {
    target_group_arn = "${var.target_group_arn}"

    // This value come from the container definitions
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
  }
}

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
