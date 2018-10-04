resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "memcached-${var.environment}"
  engine               = "memcached"
  engine_version       = "1.4.24"
  node_type            = "cache.m3.large"
  port                 = 11211
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.4"
  security_group_ids   = ["${aws_security_group.default.id}", "${aws_security_group.memcached.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.memcached.id}"
}

resource "aws_elasticache_subnet_group" "memcached" {
  name        = "memcached-${var.environment}-cache-subnet"
  description = "${var.environment} App Memcached Subnets"
  subnet_ids  = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]
}
