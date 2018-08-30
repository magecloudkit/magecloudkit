terraform {
  backend "s3" {
    bucket = "build-env-client_id"
    key    = "build-evn/thumbor-ami/terraform.tfstate"
    region = "${var.aws_region}"
  }
}