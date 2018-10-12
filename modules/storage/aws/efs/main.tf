# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

# Introduction of Local Values configuration language feature
terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE EFS FILE SYSTEM RESOURCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_efs_file_system" "main" {
  creation_token                  = "${var.creation_token}"
  encrypted                       = "${var.encrypted}"
  kms_key_id                      = "${var.kms_key_id}"
  performance_mode                = "${var.performance_mode}"
  throughput_mode                 = "${var.throughput_mode}"
  provisioned_throughput_in_mibps = "${var.provisioned_throughput_in_mibps}"

  # add tags
  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}"
    )
  )}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE EFS MOUNT TARGETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_efs_mount_target" "main" {
  count = "${length(var.availability_zones)}"

  #count          = "${length(split(",", var.subnet_ids))}"
  file_system_id = "${aws_efs_file_system.main.id}"

  subnet_id = "${element(var.subnet_ids, count.index)}"

  #subnet_id = "${element(var.subnet_ids.*.id, count.index)}"

  security_groups = ["${aws_security_group.efs.id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT CAN ACCESS THE EFS RESOURCES.
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "efs" {
  description = "Security group for the EFS mount targets"
  vpc_id      = "${var.vpc_id}"

  # add tags
  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}"
    )
  )}"
}

resource "aws_security_group_rule" "allow_inbound_from_cidr_blocks" {
  count             = "${length(var.allow_inbound_from_cidr_blocks) >= 1 ? 1 : 0}"
  type              = "ingress"
  from_port         = "${var.efs_port}"
  to_port           = "${var.efs_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allow_inbound_from_cidr_blocks}"]
  security_group_id = "${aws_security_group.efs.id}"
}

resource "aws_security_group_rule" "allow_inbound_from_security_groups" {
  count                    = "${length(var.allow_inbound_from_security_groups)}"
  type                     = "ingress"
  from_port                = "${var.efs_port}"
  to_port                  = "${var.efs_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.efs.id}"
  source_security_group_id = "${element(var.allow_inbound_from_security_groups, count.index)}"
}
