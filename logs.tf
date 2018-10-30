# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LOG GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "ecs-cluster-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}"
  retention_in_days = 30
}

module "ecs-cluster-logs-admin" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}"
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

module "ecs-audit-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/ecs/audit.log"
  retention_in_days = 7
}

module "ecs-message-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.project_name}-/var/log/messages"
  retention_in_days = 7
}
