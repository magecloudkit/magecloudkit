terraform {
  backend "s3" {
    bucket = "build-env-client_id"
    key    = "build-evn/app-ami/terraform.tfstate"
    region = "${var.aws_region}"
  }
}