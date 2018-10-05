output "public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

output "ssh_port" {
  value = "${var.ssh_port}"
}

output "security_group_id" {
  value = "${aws_security_group.bastion.id}"
}
