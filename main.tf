# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A JENKINS SERVER IN AWS
#
# This is an example of how to deploy Jenkins in AWS inside an Auto Scaling Group (ASG) with an EBS Volume attached for
# storage and an ALB.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE JENKINS INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

module "jenkins" {
  source = "./modules/ci/jenkins-server"

  cluster_name  = "${var.jenkins_cluster_name}"
  instance_type = "t2.medium"

  ami_id    = "${var.ami_id}"
  user_data = "${data.template_file.user_data_server.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  # We recommend using an EBS Volume to store the Jenkins data directory.
  ebs_block_devices = [
    {
      device_name = "${var.data_volume_device_name}"
      volume_type = "gp2"
      volume_size = 50
      encrypted   = true
    },
  ]

  # To make testing easier, we allow SSH & HTTP requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]
  allowed_http_cidr_blocks = ["0.0.0.0/0"]

  ssh_key_name = "${var.ssh_key_name}"

  # To make it easy to test this example from your computer, we allow the Jenkins servers to have public IPs. In a
  # production deployment, you'll probably want to keep all the servers in private subnets with only private IPs.
  associate_public_ip_address = true

  # We are using a load balancer for health checks so if a Jnkeinschbase node stops responding, it will automatically be
  # replaced with a new one.
  health_check_type = "ELB"

  # An example of custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH EC2 INSTANCE WHEN IT'S BOOTING
#
# This script will configure and start Jenkins
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_server" {
  template = "${file("./modules/ci/jenkins-server/user-data/user-data.sh")}"

  vars {
    http_port        = "${module.jenkins.http_port}"

    # Pass in the data about the EBS volumes so they can be mounted

    data_volume_device_name = "${var.data_volume_device_name}"
    data_volume_mount_point = "${var.data_volume_mount_point}"
    volume_owner            = "${var.volume_owner}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A LOAD BALANCER FOR JENKINS
#
# We use this load balancer to (1) perform health checks and (2) route traffic to the Jenkins Web UI.
# ---------------------------------------------------------------------------------------------------------------------

module "load_balancer" {
  source = "./modules/load-balancer/alb"

  name       = "${var.jenkins_cluster_name}"
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  http_listener_ports            = ["${var.jenkins_load_balancer_port}"]
  https_listener_ports_and_certs = []

  # To make testing easier, we allow inbound connections from any IP. In production usage, you may want to only allow
  # connections from certain trusted servers, or even use an internal load balancer, so it's only accessible from
  # within the VPC.

  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  internal                       = false

  tags = {
    Name        = "${var.jenkins_cluster_name}"
    Environment = "development"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY JENKINS IN THE DEFAULT VPC AND SUBNETS
#
# Using the default VPC and subnets makes this example easy to run and test, but it means Jenkins is accessible from
# the public Internet. For a production deployment, we strongly recommend deploying into a custom VPC with private
# subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}
