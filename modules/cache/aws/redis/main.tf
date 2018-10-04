# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE REDIS ELASTICACHE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.cluster_name}"
  engine               = "redis"
  engine_version       = "${var.engine_version}"
  node_type            = "${var.node_type}"
  port                 = "${var.port}"
  num_cache_nodes      = "${var.num_cache_nodes}"
  parameter_group_name = "${var.parameter_group_name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.name}"
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${format("%s-redis-subnet-group", var.cluster_name)}"
  description = "ElastiCache Redis Subnet Group"
  subnet_ids  = ["${var.subnet_ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH ELASTICACHE CLUSTER
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "redis" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the Redis ElastiCache resources"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_redis_inbound" {
  count       = "${length(var.allowed_redis_cidr_blocks) >= 1 ? 1 : 0}"
  type        = "ingress"
  from_port   = "${var.port}"
  to_port     = "${var.port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_redis_cidr_blocks}"]

  security_group_id = "${aws_security_group.redis.id}"
}

# TODO - does Redis need outbound?
#resource "aws_security_group_rule" "allow_redis_outbound" {
#  type        = "egress"
#  from_port   = "${var.port}"
#  to_port     = "${var.port}"
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#
#  security_group_id = "${aws_security_group.redis.id}"
#}
