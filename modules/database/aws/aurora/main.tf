# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE AWS Aurora CLUSTER

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.cluster_identifier}"
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
  count              = "${var.aws_rds_cluster_instance_count}"
  identifier         = "${var.aws_rds_cluster_instance_identifier}"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  instance_class     = "${var.instance_class}"
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.aws_db_subnet_group_name}"
  description = "${var.aws_db_subnet_group_description}"
  subnet_ids  = ["${var.subnet_ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

/* Security group for the rds instances */
resource "aws_security_group" "rds" {
  name        = "${var.aws_security_group_name}"
  description = "Security group for the Aurora instances"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "${var.port}"
    to_port   = "${var.port}"
    protocol  = "tcp"
  }

  egress {
    from_port   = "${var.egress_port}"
    to_port     = "${var.egress_port}"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
