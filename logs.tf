# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDWATCH LOG GROUPS FOR THE APP CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "ecs-cluster-logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}"
  retention_in_days = 30
}

module "ecs-cluster-logs-app-dmesg" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}-/var/log/dmesg"
  retention_in_days = 7
}

module "ecs-cluster-logs-app-docker" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}-/var/log/docker"
  retention_in_days = 7
}

module "ecs-cluster-logs-app-ecs-agent" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}-/var/log/ecs/ecs-agent.log"
  retention_in_days = 7
}

module "ecs-cluster-logs-app-ecs-init" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}-/var/log/ecs/ecs-init.log"
  retention_in_days = 7
}

module "ecs-cluster-logs-app-messages" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_app}-/var/log/messages"
  retention_in_days = 7
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDWATCH LOG GROUPS FOR THE ADMIN CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "ecs-cluster-logs-admin" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}"
  retention_in_days = 7
}

module "ecs-cluster-logs-admin-dmesg" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}-/var/log/dmesg"
  retention_in_days = 7
}

module "ecs-cluster-logs-admin-docker" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}-/var/log/docker"
  retention_in_days = 7
}

module "ecs-cluster-logs-admin-ecs-agent" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}-/var/log/ecs/ecs-agent.log"
  retention_in_days = 7
}

module "ecs-cluster-logs-admin-ecs-init" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}-/var/log/ecs/ecs-init.log"
  retention_in_days = 7
}

module "ecs-cluster-logs-admin-messages" {
  source = "./modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name_admin}-/var/log/messages"
  retention_in_days = 7
}
