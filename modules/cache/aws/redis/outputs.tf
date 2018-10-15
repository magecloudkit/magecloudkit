output "redis_port" {
  value = "${var.port}"
}

output "security_group_id" {
  value = "${aws_security_group.redis.id}"
}

output "primary_address" {
  value = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
}
