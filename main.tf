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
