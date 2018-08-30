resource "aws_rds_cluster" "default" {
  cluster_identifier      = "rds-${terraform.workspace}-aurora-cluster"
  database_name           = "magento2"
  master_username         = "magento2"
  master_password         = "${lookup(var.rds_password, terraform.workspace)}"
  backup_retention_period = 7
  preferred_backup_window = "01:00-02:00"
  vpc_security_group_ids  = ["${aws_security_group.default.id}", "${aws_security_group.rds.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "rds-${terraform.workspace}-aurora-cluster-${count.index}"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  instance_class     = "db.t2.medium"
}

resource "aws_db_subnet_group" "default" {
  name        = "aurora-${terraform.workspace}-default-subnet-group"
  description = "${terraform.workspace} RDS Aurora Subnets"
  subnet_ids  = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]
}

/* Security group for the rds instances */
resource "aws_security_group" "rds" {
  name        = "sg_${terraform.workspace}_rds"
  description = "Security group for the RDS instances"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-${terraform.workspace}-rds"
    Environment = "${terraform.workspace}"
  }

  depends_on = [
    "aws_security_group.app",
  ]
}
