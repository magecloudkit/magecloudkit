# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE AWS PROVIDER
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# Require a modern version of Terraform so we have access to the recent features.
terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS CLUSTER IN THE DEFAULT VPC
# ---------------------------------------------------------------------------------------------------------------------
module "redis" {
  source = "./modules/cache/aws/redis"

  cluster_id = "redis-production"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE MEMCACHED CLUSTER IN THE DEFAULT VPC
# ---------------------------------------------------------------------------------------------------------------------
module "memcached" {
  source = "./modules/cache/aws/memcached"

  cluster_id = "memcached-production"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"
}
