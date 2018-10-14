# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN AURORA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "aurora" {
  source = "../../modules/database/aws/aurora"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  cluster_identifier      = "${var.project_name}-aurora-cluster"
  cluster_instance_prefix = "${var.project_name}-aurora-cluster-instance"
  database_name           = "magento2"
  master_username         = "magento2"
  master_password         = "magento2"
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"
}

# Generate a random RDS master password, you can use this password by referencing: ${random_string.rds_password.result}
#resource "random_string" "rds_password" {
#  length           = 30
#  special          = true
#  override_special = "/@"
#}

