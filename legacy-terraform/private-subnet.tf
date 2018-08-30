/* Private subnet */
resource "aws_subnet" "private_az1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.private_subnet_az1_cidr}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  depends_on              = ["aws_internet_gateway.default"]

  tags {
    Name = "${terraform.workspace} private az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.private_subnet_az2_cidr}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  depends_on              = ["aws_internet_gateway.default"]

  tags {
    Name = "${terraform.workspace} private az2"
  }
}

resource "aws_subnet" "private_az3" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.private_subnet_az3_cidr}"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  depends_on              = ["aws_internet_gateway.default"]

  tags {
    Name = "${terraform.workspace} private az3"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count  = "3"
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.ipv6egress.id}"
  }

  tags {
    Environment = "${terraform.workspace}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count          = "3"
  subnet_id      = "${element(split(",", "${aws_subnet.private_az1.id},${aws_subnet.private_az2.id},${aws_subnet.private_az3.id}"), count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
