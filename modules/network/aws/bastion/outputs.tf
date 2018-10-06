output "public_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.instance.id}"
}

output "ssh_port" {
  value = "${var.ssh_port}"
}

output "security_group_id" {
  value = "${aws_security_group.bastion.id}"
}
