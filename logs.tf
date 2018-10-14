# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LOGS GROUP
# ---------------------------------------------------------------------------------------------------------------------

module "ecs-cluster-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name}"
  retention_in_days = 30
}

module "dmesg-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/dmesg"
  retention_in_days = 7
}

module "docker-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/docker"
  retention_in_days = 7
}

module "ecs-agent-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/ecs/ecs-agent.log"
  retention_in_days = 7
}

module "ecs-init-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/ecs/ecs-init.log"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs-audit-logs" {
  name              = "${var.cloudwatch_prefix}/var/log/ecs/audit.log"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "message-logs" {
  name              = "${var.cloudwatch_prefix}/var/log/messages"
  retention_in_days = 7
}
