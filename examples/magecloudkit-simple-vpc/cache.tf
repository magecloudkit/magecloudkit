# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS CACHE CLUSTER
#
# This cluster is used to store cache data.
# ---------------------------------------------------------------------------------------------------------------------

module "redis_cache" {
  source = "../../modules/cache/aws/redis"

  cluster_name = "${var.environment}-cache"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  # Limit access to the App servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # An example of custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS SESSION CLUSTER
#
# This cluster is used to store session data.
# ---------------------------------------------------------------------------------------------------------------------

module "redis_session" {
  source = "../../modules/cache/aws/redis"

  cluster_name = "${var.environment}-session"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"

  # Limit access to the App servers only
  allowed_inbound_security_group_count = 1
  allowed_inbound_security_group_ids   = ["${module.app_cluster.security_group_id}"]

  # An example of custom tags
  tags = [
    {
      Environment = "${var.environment}"
    },
  ]
}
