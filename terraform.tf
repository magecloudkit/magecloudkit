terraform {
  # Require a modern version of Terraform so we have access to the recent features.
  required_version = ">= 0.10.3"

  # Also configure remote state for working in teams.
  backend "s3" {
    bucket = "kiwico-state"
    key    = "env/production/terraform.tfstate"
    region = "us-west-1"
  }
}
