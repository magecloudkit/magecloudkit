# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN EFS FILE SYSTEM FOR STORING MEDIA ASSETS
# ---------------------------------------------------------------------------------------------------------------------

module "efs" {
  source = "../../modules/storage/aws/efs"

  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = "${data.aws_availability_zones.available.names}"
  subnet_ids         = "${module.vpc.persistence_subnets}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]

  allow_inbound_from_security_groups = []

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}
