output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

// A comma-separated list of Public Subnet IDs.
output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

// A comma-separated list of Private Subnet IDs.
output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

// A comma-separated list of Persistence Subnet IDs.
output "persistence_subnets" {
  value = ["${aws_subnet.persistence.*.id}"]
}

// The list of Availability Zones of the VPC.
output "availability_zones" {
  value = ["${aws_subnet.public.*.availability_zone}"]
}

// The private route table ID.
output "private_rtb_id" {
  value = "${join(",", aws_route_table.private.*.id)}"
}

// The public route table ID.
output "public_rtb_id" {
  value = "${aws_route_table.public.id}"
}

// The list of EIPs associated with the private subnets.
output "private_nat_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}
