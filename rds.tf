# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE AURORA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "aurora" {
  source = "./modules/database/aws/aurora"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  cluster_identifier      = "${var.project_name}-aurora-cluster"
  cluster_instance_prefix = "${var.project_name}-aurora-cluster-instance"
  instance_class          = "db.r4.2xlarge"
  database_name           = "magento2"
  master_username         = "magento2"
  master_password         = "production"
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"

  # Limit access to app servers only
  allowed_db_security_group_count = 2
  allowed_db_security_group_ids   = ["${module.app_cluster.security_group_id}", "${module.admin_cluster.security_group_id}"]
}
