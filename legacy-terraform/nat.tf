resource "aws_eip" "nat" {
  count = "3"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

// create a nat gateway for each availability zone
resource "aws_nat_gateway" "nat" {
  count         = "3"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(split(",", "${aws_subnet.public_az1.id},${aws_subnet.public_az2.id},${aws_subnet.public_az3.id}"), count.index)}"
  depends_on    = ["aws_internet_gateway.default"]
}
