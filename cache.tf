# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "redis" {
  source = "./modules/cache/aws/redis"

  cluster_name = "redis-production"
  node_type    = "cache.t2.small"

  vpc_id                             = "${module.vpc.vpc_id}"
  subnet_ids                         = "${module.vpc.persistence_subnets}"
  allowed_inbound_security_group_ids = ["${module.app_cluster.security_group_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE MEMCACHED CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "memcached" {
  source = "./modules/cache/aws/memcached"

  cluster_name = "memcached-production"
  node_type    = "cache.t2.small"

  vpc_id                             = "${module.vpc.vpc_id}"
  subnet_ids                         = "${module.vpc.persistence_subnets}"
  allowed_inbound_security_group_ids = ["${module.app_cluster.security_group_id}"]
}
