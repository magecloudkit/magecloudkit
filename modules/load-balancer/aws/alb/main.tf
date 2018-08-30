# ---------------------------------------------------------------------------------------------------------------------
# AWS ALB Modules
# This module allows you to deploy an AWS ALB load balancer.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.0"
}

resource "aws_alb" "main" {
  name            = "${terraform.workspace}-app-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb_web.id}"]
  subnets         = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]

  access_logs {
    bucket = "${aws_s3_bucket.logs.id}"
    prefix = "${terraform.workspace}-app-alb"
  }

  tags {
    Name        = "${terraform.workspace}-app-alb"
    Environment = "${terraform.workspace}"
  }
}
