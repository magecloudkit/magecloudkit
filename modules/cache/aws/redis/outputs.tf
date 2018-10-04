output "redis_port" {
  value = "${var.port}"
}

output "security_group_id" {
  value = "${aws_security_group.redis.id}"
}
