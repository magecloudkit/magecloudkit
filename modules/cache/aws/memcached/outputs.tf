output "memcached_port" {
  value = "${var.port}"
}

output "security_group_id" {
  value = "${aws_security_group.memcached.id}"
}

output "primary_address" {
  value = "${aws_elasticache_cluster.memcached.cache_nodes.0.address}"
}
