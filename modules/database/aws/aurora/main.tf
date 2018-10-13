# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE RDS AURORA CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.cluster_identifier}"
  engine                  = "${var.engine}"
  engine_version          = "${var.engine_version}"
  database_name           = "${var.database_name}"
  master_username         = "${var.master_username}"
  master_password         = "${var.master_password}"
  backup_retention_period = "${var.backup_retention_period}"
  preferred_backup_window = "${var.preferred_backup_window}"
  vpc_security_group_ids  = ["${aws_security_group.rds.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = "${var.cluster_instance_count}"
  identifier         = "${format("%s-%03d", var.cluster_instance_prefix, count.index+1)}"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  instance_class     = "${var.instance_class}"
  engine             = "${var.engine}"
  engine_version     = "${var.engine_version}"
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.cluster_identifier}-subnet-group"
  description = "RDS Aurora Subnets"
  subnet_ids  = ["${var.subnet_ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

/* Security group for the rds instances */
resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_identifier}"
  description = "Security group for the Aurora instances"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_inbound" {
  count       = "${length(var.allowed_db_cidr_blocks) >= 1 ? 1 : 0}"
  type        = "ingress"
  from_port   = "${var.port}"
  to_port     = "${var.port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_db_cidr_blocks}"]

  security_group_id = "${aws_security_group.rds.id}"
}

resource "aws_security_group_rule" "allow_db_access_from_security_group_ids" {
  count                    = "${length(var.allowed_db_security_group_ids)}"
  type                     = "ingress"
  from_port                = "${var.port}"
  to_port                  = "${var.port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.allowed_db_security_group_ids, count.index)}"

  security_group_id = "${aws_security_group.rds.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.rds.id}"
}
