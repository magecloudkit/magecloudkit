resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = "${terraform.workspace}-cache"
  engine               = "redis"
  engine_version       = "3.2.4"
  node_type            = "cache.t2.small"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  security_group_ids   = ["${aws_security_group.default.id}", "${aws_security_group.redis.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.id}"
}

resource "aws_elasticache_cluster" "redis_session" {
  cluster_id           = "${terraform.workspace}-session"
  engine               = "redis"
  engine_version       = "3.2.4"
  node_type            = "cache.t2.small"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  security_group_ids   = ["${aws_security_group.default.id}", "${aws_security_group.redis.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.id}"
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "redis-${terraform.workspace}-subnet"
  description = "${terraform.workspace} Redis Subnets"
  subnet_ids  = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]
}

/* Security group for the redis servers */
resource "aws_security_group" "redis" {
  name        = "sg_${terraform.workspace}_redis"
  description = "Security group for the Redis servers"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-${terraform.workspace}-redis"
    Environment = "${terraform.workspace}"
  }

  depends_on = [
    "aws_security_group.app",
  ]
}
