# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

# This instance is used for caching
module "redis_cache" {
  source = "./modules/cache/aws/redis"

  cluster_name = "${var.environment}-cache"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  # Limit access to app servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # Set custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}

# This instance is used to store session data
module "redis_session" {
  source = "./modules/cache/aws/redis"

  cluster_name = "${var.environment}-session"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  # Limit access to app servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # Set custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE MEMCACHED CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "memcached" {
  source = "./modules/cache/aws/memcached"

  cluster_name = "${var.environment}-memcached"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  # Limit access to app servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # Set custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}
