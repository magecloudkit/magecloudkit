# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN EFS FILE SYSTEM FOR STORING MEDIA ASSETS
# ---------------------------------------------------------------------------------------------------------------------

module "efs" {
  source = "./modules/storage/aws/efs"

  name               = "${var.project_name}"
  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = "${var.availability_zones}"
  subnet_ids         = "${module.vpc.persistence_subnets}"

  # Limit access to app servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # An example of custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}
