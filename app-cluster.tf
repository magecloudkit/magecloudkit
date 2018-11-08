# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "app_cluster" {
  source = "./modules/app-cluster/aws/ecs-cluster"

  cluster_name  = "${var.ecs_cluster_name_app}"
  instance_type = "c5.large"

  user_data = "${data.template_file.user_data_ecs.rendered}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  min_size         = 8
  max_size         = 12
  desired_capacity = 8

  # Allow inbound SSH access from the Bastion instance
  allowed_ssh_security_group_ids = ["${module.bastion.security_group_id}"]

  key_pair_name = "${var.key_pair_name}"

  # We recommend using a separate EBS Volume for the Docker data dir
  ebs_block_devices = [
    {
      device_name = "/dev/xvdcz"
      volume_type = "gp2"
      volume_size = 50
    },
  ]

  # Autoscaling Properties
  enable_autoscaling                        = true
  ecs_instance_draining_lambda_function_arn = "${module.ecs_draining.lambda_function_arn}"

  autoscaling_properties = [
    {
      type               = "CPUReservation"
      direction          = "up"
      evaluation_periods = 2
      observation_period = "300"
      statistic          = "Average"
      threshold          = "89"
      cooldown           = "900"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "1"
    },
    {
      type               = "CPUReservation"
      direction          = "down"
      evaluation_periods = 4
      observation_period = "300"
      statistic          = "Average"
      threshold          = "10"
      cooldown           = "300"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "-1"
    },
    {
      type               = "MemoryReservation"
      direction          = "up"
      evaluation_periods = 2
      observation_period = "300"
      statistic          = "Average"
      threshold          = "50"
      cooldown           = "900"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "1"
    },
    {
      type               = "MemoryReservation"
      direction          = "down"
      evaluation_periods = 4
      observation_period = "300"
      statistic          = "Average"
      threshold          = "10"
      cooldown           = "300"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "-1"
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

data "template_file" "user_data_ecs" {
  template = "${file("./modules/app-cluster/aws/ecs-cluster/user-data/user-data.sh")}"

  vars {
    environment  = "${var.environment}"
    cluster_name = "${var.ecs_cluster_name_app}"
    aws_region   = "${var.aws_region}"

    enable_efs         = 1
    efs_file_system_id = "${module.efs.efs_filesystem_id}"
    efs_mount_point    = "${var.media_volume_mount_point}"

    # block_metadata_service blocks the aws metadata service from the ECS Tasks true / false
    block_metadata_service = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE ECS DRAINING LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_draining" {
  source = "./modules/app-cluster/aws/ecs-instance-draining"
  name   = "${var.ecs_cluster_name_app}"
}
