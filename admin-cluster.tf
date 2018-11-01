# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ECS CLUSTER FOR THE ADMIN CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "admin_cluster" {
  source = "./modules/app-cluster/aws/ecs-cluster"

  cluster_name  = "${var.ecs_cluster_name_admin}"
  ami_id        = "${var.ecs_ami}"
  instance_type = "c5.2xlarge"

  user_data = "${data.template_file.user_data_ecs_admin.rendered}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  # Allow inbound SSH access from the Bastion instance
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]

  key_pair_name = "${var.key_pair_name}"

  # We recommend using a separate EBS Volume for the Docker data directory
  ebs_block_devices = [
    {
      device_name = "/dev/xvdcz"
      volume_type = "gp2"
      volume_size = 50
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
# THE USER DATA SCRIPT THAT WILL RUN ON THE ECS INSTANCES WHEN THEY ARE BOOTING
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_ecs_admin" {
  template = "${file("./modules/app-cluster/aws/ecs-cluster/user-data/user-data.sh")}"

  vars {
    environment = "${var.environment}"
    cluster     = "${var.ecs_cluster_name_admin}"
    aws_region  = "${var.aws_region}"

    mysql_host     = "${aws_route53_record.db.fqdn}"
    mysql_database = "${var.env_mysql_database}"
    mysql_user     = "${var.env_mysql_user}"
    mysql_password = "${var.env_mysql_password}"
  }
}
