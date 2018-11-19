# Jenkins Server Module

This module deploys a Jenkins cluster inside an EC2 Auto Scaling Group. It uses an Amazon EFS filesystem to store
the Jenkins data directory and an ALB load balancer for health checks. It supports automatic replacement of failed
nodes and reattaches the same filesystem in the event of a failure. It requires an AMI with Jenkins installed,
ideally built using the [`jenkins-ami`](../jenkins-ami/README.md) module.

Please read [Deploying Jenkins on AWS](https://docs.aws.amazon.com/aws-technical-content/latest/jenkins-on-aws/deploying-jenkins-on-aws.html)
for more information on the inspiration of this module.

## Features

 * An EC2 Auto Scaling Group for running the Jenkins instances.
 * An EFS filesystem for persisting data between restarts.
 * Security Groups
 * IAM Roles & Permissions

## Usage

Sample module usage:

```hcl
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY JENKINS INSIDE AN AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

module "jenkins" {
  source = "./modules/ci/aws/jenkins-server"

  name          = "production-jenkins"
  efs_name      = "production-jenkins"
  environment   = "production"
  ami_id        = "ami-XXYYZZZZ"
  instance_type = "t3.xlarge"

  user_data = "${data.template_file.user_data_jenkins.rendered}"

  # Run Jenkins instances in all availability zones
  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = "${var.availability_zones}"
  subnet_ids         = "${module.vpc.private_subnets}"
  efs_subnet_ids     = "${module.vpc.persistence_subnets}"

  # Allow inbound SSH access from the Bastion instance
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]
  key_pair_name                  = "${var.key_pair_name}"

  # Provide the ALB target groups
  target_group_arns = ["${module.alb_jenkins.target_group_arns}"]]

  # Set custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "production"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON THE JENKINS EC2 INSTANCES WHEN THEY ARE BOOTING
#
# This script will ensure the correct EBS volume is attached and start the Jenkins software.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_jenkins" {
  template = "${file("./modules/jenkins-server/user-data/user-data.sh")}"

  vars {
    http_port                 = "${var.jenkins_http_port}"
    jenkins_efs_filesystem_id = "${module.jenkins.efs_filesystem_id}"
    media_efs_filesystem_id   = "${module.efs.efs_filesystem_id}"
    data_volume_mount_point   = "${module.jenkins.volume_mountpoint}"
    media_volume_mount_point  = "${var.media_volume_mount_point}"
    volume_owner              = "${module.jenkins.volume_owner}"
  }
}

module "alb_jenkins" {
  source = "./modules/load-balancer/aws/alb"

  name       = "${var.environment}-jenkins-alb"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.public_subnets}"

  security_groups = ["${aws_security_group.alb_jenkins.id}"]

  # we disable logs for the jenkins alb
  logging_enabled = false

  # Enable HTTPS
  https_listeners       = "${list(map("certificate_arn", "arn:aws:acm:us-east-1:123456789012:certificate/a0b5c3fc-67fd-4fc6-8dc4-46606ab17788", "port", 443))}"
  https_listeners_count = "1"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "jenkins-ci", "backend_protocol", "HTTP", "backend_port", "8080"))}"
  target_groups_count      = "1"

  # An example of custom tags
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "alb_jenkins" {
  description = "Security group for the Jenkins ALB that allows web traffic from internet"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-sg-alb-jenkins"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "alb_to_jenkins" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 8080
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.alb_jenkins.id}"
  security_group_id        = "${module.jenkins.security_group_id}"
}
```
