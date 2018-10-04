# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE AWS PROVIDER
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A BASTION SERVER IN AWS
#
# This is an example of how to deploy Jenkins in AWS inside an Auto Scaling Group (ASG) with an EBS Volume attached for
# storage and an ALB.
# ---------------------------------------------------------------------------------------------------------------------

# Require a modern version of Terraform so we have access to the recent features.
terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BASTION NODE IN THE DEFAULT VPC
# ---------------------------------------------------------------------------------------------------------------------

module "bastion" {
  source = "./modules/network/aws/bastion"

  instance_type = "t2.medium"

  user_data = "${data.template_file.user_data_bastion.rendered}"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  ssh_key_name = "${var.ssh_key_name}"

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON THE BASTION INSTANCE WHEN IT'S BOOTING
#
# This script will configure the Bastion instance.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_bastion" {
  template = "${file("./modules/network/aws/bastion/user-data/user-data.sh")}"

  vars {
    ssh_port = "${module.bastion.ssh_port}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BASTION INSTANCE IN THE DEFAULT VPC AND SUBNETS
#
# Using the default VPC and subnets makes this example easy to run and test.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}
