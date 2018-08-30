/* Default security group for all instances */
resource "aws_security_group" "default" {
  name        = "sg_${terraform.workspace}_default"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = "${aws_vpc.default.id}"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-${terraform.workspace}-default"
    Environment = "${terraform.workspace}"
  }
}

/* Security group for the public facing load balancers */
resource "aws_security_group" "alb_web" {
  name        = "sg_${terraform.workspace}_alb_web"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = "${aws_vpc.default.id}"

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
    Name        = "sg-${terraform.workspace}-alb-web"
    Environment = "${terraform.workspace}"
  }
}
