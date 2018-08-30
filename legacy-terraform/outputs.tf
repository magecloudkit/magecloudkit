output "bastion.ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "alb_name" {
  value = "${aws_alb.app.dns_name}"
}
