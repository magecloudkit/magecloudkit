# ---------------------------------------------------------------------------------------------------------------------
# DEFINE MINIMUM TERRAFORM VERSION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# MEMCACHED
# CREATE THE ELASTIC CACHE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "${var.cluster_id}"
  engine               = "memcached"
  engine_version       = "${var.engine_version}"
  node_type            = "${var.node_type}"
  port                 = "${var.port}"
  num_cache_nodes      = "${var.num_cache_nodes}"
  parameter_group_name = "${var.parameter_group_name}"
  security_group_ids   = ["${aws_security_group.memcached.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.memcached.name}"
}

resource "aws_elasticache_subnet_group" "memcached" {
  name        = "${var.subnet_group_name}"
  description = "${var.subnet_group_description}"
  subnet_ids  = ["${var.subnet_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH ELASTICACHE CLUSTER
# We export the ID of the security group as an output variable so users can attach custom rules.
# ---------------------------------------------------------------------------------------------------------------------

/* Security group for the memcached servers */
resource "aws_security_group" "memcached" {
  name        = "${var.security_group_name}"
  description = "${var.security_group_description}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "${var.memcached_port}"
    to_port   = "${var.memcached_port}"
    protocol  = "tcp"
  }

  ingress {
    from_port = "${var.memcached_port}"
    to_port   = "${var.memcached_port}"
    protocol  = "tcp"
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}
