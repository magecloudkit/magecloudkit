output "public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

output "ssh_port" {
  value = "${var.ssh_port}"
}
