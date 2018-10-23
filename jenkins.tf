# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY JENKINS INSIDE AN AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

module "jenkins" {
  source = "./modules/ci/aws/jenkins-server"

  name          = "${var.environment}-jenkins"
  efs_name      = "${var.project_name}-jenkins"
  environment   = "${var.environment}"
  ami_id        = "${var.jenkins_ami}"
  instance_type = "c5.large"

  user_data = "${data.template_file.user_data_jenkins.rendered}"

  # Run Jenkins instances in all availability zones
  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = "${var.availability_zones}"
  subnet_ids         = "${module.vpc.private_subnets}"
  efs_subnet_ids     = "${module.vpc.persistence_subnets}"

  # Allow inbound SSH access from the Bastion instance
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]

  key_pair_name = "${var.key_pair_name}"

  # Provide the ALB target groups
  target_group_arns = ["${module.alb_jenkins.target_group_arns}"]

  # Store the Jenkins data directory on a seperate EBS volume. This allows the instances to persist data between restarts.
  ebs_block_devices = [
    {
      device_name = "/dev/xvdh"
      volume_type = "gp2"
      volume_size = 120
    },
  ]

  # Set custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
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
  template = "${file("./modules/ci/aws/jenkins-server/user-data/user-data.sh")}"

  vars {
    http_port               = "${var.jenkins_http_port}"
    efs_filesystem_id       = "${module.jenkins.efs_filesystem_id}"
    data_volume_mount_point = "${module.jenkins.volume_mountpoint}"
    volume_owner            = "${module.jenkins.volume_owner}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ALB LOAD BALANCER TO ALLOW JENKINS TRAFFIC
# ---------------------------------------------------------------------------------------------------------------------

module "alb_jenkins" {
  source = "./modules/load-balancer/aws/alb"

  name       = "${var.environment}-jenkins-alb"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.public_subnets}"

  security_groups = ["${aws_security_group.alb_jenkins.id}"]

  # we disable logs for the jenkins alb
  logging_enabled = false

  # Enable HTTPS on the load balancer. We are referencing the KiwiCo 'KiwiCoGoDaddy' certificate.
  https_listeners       = "${list(map("certificate_arn", "arn:aws:acm:us-west-1:054130723771:certificate/1a6b062a-4225-443a-a981-47a40aba62fb", "port", 443))}"
  https_listeners_count = "1"

  http_tcp_listeners       = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "${var.project_name}-ci-tg", "backend_protocol", "HTTP", "backend_port", "8080"))}"
  target_groups_count      = "1"

  # An example of custom tags
  tags = {
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SECURITY GROUPS FOR JENKINS=
# ---------------------------------------------------------------------------------------------------------------------

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
