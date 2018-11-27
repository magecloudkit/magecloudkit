# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDWATCH LOG GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "ecs-cluster-logs" {
  source = "../../modules/monitoring/aws/logs"

  name              = "${var.ecs_cluster_name}"
  retention_in_days = 3
}

module "cron_logs" {
  source = "../../modules/monitoring/aws/logs"

  name              = "${var.environment}-cron"
  retention_in_days = 3
}
