# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.39"
}

provider "template" {
  version = "~> 1.0"
}

provider "random" {
  version = "~> 2.0"
}

# Require a modern version of Terraform so we have access to the recent features like locals.
terraform {
  required_version = ">= 0.10.3"
}
