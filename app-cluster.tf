# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "./modules/app-cluster/aws/ecs-cluster"

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
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]

  ssh_key_name = "${var.ssh_key_name}"

  # custom docker volume
  #ebs_block_device {
  #  device_name = "/dev/xvdcz"
  #  volume_type = "gp2"
  #  volume_size = "25"
  #}

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
# THE USER DATA SCRIPT THAT WILL RUN ON THE ECS INSTANCES WHEN THEY ARE BOOTING
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_ecs" {
  template = "${file("./modules/app-cluster/aws/ecs-cluster/user-data/user-data.sh")}"

  vars {
    environment = "${var.environment}"
    cluster     = "${var.ecs_cluster_name}"
    aws_region  = "${var.aws_region}"

    mysql_host     = "db.magecloudkit.internal"
    mysql_database = "magento"
    mysql_user     = "magento"
    mysql_password = "magento"

    #mysql_host     = "${aws_route53_record.db.fqdn}"
    #mysql_database = "${var.env_mysql_database}"
    #mysql_user     = "${var.env_mysql_user}"
    #mysql_password = "${lookup(var.rds_password, terraform.workspace)}"
  }
}
