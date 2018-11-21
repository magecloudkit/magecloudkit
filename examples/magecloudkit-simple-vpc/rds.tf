# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN AURORA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "aurora" {
  source = "../../modules/database/aws/aurora"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  cluster_identifier      = "${var.project_name}-aurora-cluster"
  cluster_instance_prefix = "${var.project_name}-aurora-cluster-instance"
  database_name           = "${var.env_mysql_host}"
  master_username         = "${var.env_mysql_user}"
  master_password         = "${var.env_mysql_password}"
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"

  # Limit access to the App servers only
  allowed_db_security_group_count = 1
  allowed_db_security_group_ids   = ["${module.app_cluster.security_group_id}"]
}
