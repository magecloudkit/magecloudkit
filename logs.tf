# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDWATCH LOG GROUPS
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
