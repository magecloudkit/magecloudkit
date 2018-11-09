# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

# Introduction of Local Values configuration language feature
terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECS CLUSTER RESOURCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP TO CONTAIN THE EC2 INSTANCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "autoscaling_group" {
  name = "${var.cluster_name}-${aws_launch_configuration.launch_configuration.name}"

  launch_configuration = "${aws_launch_configuration.launch_configuration.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  termination_policies = ["${var.termination_policies}"]

  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    },
    "${var.tags}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}"
  image_id      = "${length(var.ami_id) >= 1 ? var.ami_id : format("%s", data.aws_ami.ecs_ami.id)}"
  instance_type = "${var.instance_type}"
  user_data     = "${var.user_data}"
  spot_price    = "${var.spot_price}"

  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  key_name                    = "${var.key_pair_name}"
  security_groups             = ["${aws_security_group.lc_security_group.id}"]
  placement_tenancy           = "${var.tenancy}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_optimized = "${var.root_volume_ebs_optimized}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
    iops                  = "${var.root_volume_iops}"
  }

  ebs_block_device = "${var.ebs_block_devices}"

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lc_security_group" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the ECS instances that allows inbound SSH access and all outbound traffic."
  vpc_id      = "${var.vpc_id}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_cidr_blocks" {
  count             = "${length(var.allowed_ssh_cidr_blocks) >= 1 ? 1 : 0}"
  type              = "ingress"
  from_port         = "${var.ssh_port}"
  to_port           = "${var.ssh_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed_ssh_cidr_blocks}"]
  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_security_group_ids" {
  count                    = "${length(var.allowed_ssh_security_group_ids)}"
  type                     = "ingress"
  from_port                = "${var.ssh_port}"
  to_port                  = "${var.ssh_port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.allowed_ssh_security_group_ids, count.index)}"

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lc_security_group.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS CLI without having to figure out
# how to get our secret AWS access keys onto the box. We export the ID of the IAM role as an output variable so users
# can attach custom policies.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.cluster_name}-instance-profile"
  path        = "${var.instance_profile_path}"
  role        = "${aws_iam_role.instance_role.name}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance_role.json}"

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

# Make sure the ECS instances have the appriopriate policy attached so they can register themselves in the ECS cluster
resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Allow the ECS instances to write CloudWatch logs
resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Look up the latest version of the AWS ECS Optimized AMI
data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-${var.ami_version}-amazon-ecs-optimized*"]
  }
}
