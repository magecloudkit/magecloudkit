# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

# Introduction of Local Values configuration language feature
terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC RESOURCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  # add tags
  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}"
    )
  )}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN INTERNET GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}"
    )
  )}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN EGRESS ONLY INTERNET GATEWAY
# This is used for outbound only communication over IPv6. It prevents hosts outside initiating inbound connections.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_egress_only_internet_gateway" "ipv6egress" {
  vpc_id = "${aws_vpc.main.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE ELASTIC IPS FOR THE NAT GATEWAYS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = "${length(var.public_subnets)}"
  vpc   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE NAT GATEWAYS
# Create a NAT Gateway for each availability zone.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SUBNETS
# Create 3 tiers of subnets.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${length(var.public_subnets)}"
  map_public_ip_on_launch = true

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}-${format("public-%03d", count.index+1)}"
    )
  )}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.private_subnets)}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}-${format("private-%03d", count.index+1)}"
    )
  )}"
}

resource "aws_subnet" "persistence" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.persistence_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.persistence_subnets)}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}-${format("persistence-%03d", count.index+1)}"
    )
  )}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ROUTE TABLES AND ROUTES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}-public-001"
    )
  )}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}-${format("private-%03d", count.index+1)}"
    )
  )}"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ROUTE ASSOCIATIONS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
