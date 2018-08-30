resource "aws_efs_file_system" "media" {
  creation_token = "${var.project_name}-${terraform.workspace}-media"
  tags {
    Name = "${terraform.workspace}-media"
  }
}

resource "aws_efs_mount_target" "az1" {
  file_system_id = "${aws_efs_file_system.media.id}"
  subnet_id = "${aws_subnet.private_az1.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id = "${aws_efs_file_system.media.id}"
  subnet_id = "${aws_subnet.private_az2.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "az3" {
  file_system_id = "${aws_efs_file_system.media.id}"
  subnet_id = "${aws_subnet.private_az3.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}


/* Security group for the efs nodes */
resource "aws_security_group" "efs" {
  name = "sg_${terraform.workspace}_efs"
  description = "Security group for the EFS nodes"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  tags {
    Name = "sg-${terraform.workspace}-efs"
    Environment = "${terraform.workspace}"
  }
}
