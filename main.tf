# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE AWS PROVIDER
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.39"
}

provider "template" {
  version = "~> 1.0"
}

terraform {
  # Require a modern version of Terraform so we have access to the recent features.
  required_version = ">= 0.10.3"

  # Also configure remote state for working in teams.
  backend "s3" {
    bucket = "brightfame-state"
    key    = "terraform"
    region = "us-west-1"
  }
}
