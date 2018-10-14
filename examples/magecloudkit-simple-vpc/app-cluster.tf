# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "../../modules/app-cluster/aws/ecs-cluster"

  cluster_name  = "${var.ecs_cluster_name}"
  ami_id        = "${var.ecs_ami}"
  instance_type = "c5.large"

  user_data = "${data.template_file.user_data_ecs.rendered}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  # Allow inbound SSH access from the Bastion instance
  #allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]
  #allowed_ssh_security_group_ids = ["${aws_security_group.bastion.id}"]

  key_pair_name = "${var.key_pair_name}"
  # We recommend using a separate EBS Volume for the Docker data dir
  ebs_block_devices = [
    {
      device_name = "/dev/xvdcz"
      volume_type = "gp2"
      volume_size = 50
    },
  ]
  # An example of custom tags
  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON THE ECS INSTANCES WHEN THEY ARE BOOTING
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_ecs" {
  template = "${file("../../modules/app-cluster/aws/ecs-cluster/user-data/user-data.sh")}"

  vars {
    environment = "${var.environment}"
    cluster     = "${var.ecs_cluster_name}"
    aws_region  = "${var.aws_region}"

    mysql_host     = "db.magecloudkit.internal"
    mysql_database = "magento"
    mysql_user     = "magento"
    mysql_password = "magento"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ALB LOAD BALANCER TO SERVE TRAFFIC TO THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "../../modules/load-balancer/aws/alb"

  name       = "${var.environment}-app-alb"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.public_subnets}"

  security_groups = ["${aws_security_group.alb_web.id}"]

  create_log_bucket   = true
  log_bucket_name     = "${var.project_name}-alb-logs"
  log_location_prefix = "app-alb-logs"

  # Uncomment these listeners if you want to enable HTTPS on the load balancer.
  # Note: You must specify the ARN to an ACM or IAM SSL certificate.
  #https_listeners          = "${list(map("certificate_arn", "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012", "port", 443))}"
  #https_listeners_count    = "1"
  http_tcp_listeners = "${list(map("port", "80", "protocol", "HTTP"))}"

  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "foo", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "1"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  #allowed_ssh_cidr_blocks = ["0.0.0.0/0"]


  # Allow inbound SSH access from the Bastion instance
  #allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]
  #allowed_ssh_security_group_ids = ["${aws_security_group.bastion.id}"]

  # An example of custom tags
  tags = {
    Environment = "${var.environment}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb_web" {
  name        = "${var.environment}-sg-alb-web"
  description = "Security group for the ALB that allows web traffic from internet"
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
    Name        = "${var.environment}-sg-alb-web"
    Environment = "${var.environment}"
  }
}
