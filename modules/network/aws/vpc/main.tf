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
# CREATE DHCP RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_dhcp_options" "main" {
  count = "${var.enable_dhcp ? 1 : 0}"

  domain_name         = "${var.dhcp_domain_name}"
  domain_name_servers = "${var.dhcp_domain_name_servers}"

  # add tags
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-dhcp-options", var.name)
    )
  )}"
}

resource "aws_vpc_dhcp_options_association" "main" {
  count = "${var.enable_dhcp ? 1 : 0}"

  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
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
  count         = "${local.subnet_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SUBNETS
# Create 3 tiers of subnets.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # This works as long as we want the same number of subnets in each AZ
  subnet_count = "${min(length(var.availability_zones), length(var.public_subnets), length(var.private_subnets), length(var.persistence_subnets))}"

  #nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  count                   = "${local.subnet_count}"
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
  count             = "${local.subnet_count}"

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
  count             = "${local.subnet_count}"

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
  count  = "${local.subnet_count}"
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
  count          = "${local.subnet_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${local.subnet_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
