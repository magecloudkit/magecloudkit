// provider configuration
terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

#locals {
#  max_subnet_length = "${max(length(var.private_subnets), length(var.elasticache_subnets), length(var.database_subnets), length(var.redshift_subnets))}"
#  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"
#}

// create the resources
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}
