terraform {
  backend "s3" {
    bucket = "production-env-client_id"
    key    = "production-evn/terraform.tfstate"
    region = "${var.aws_region}"
  }
}