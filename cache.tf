# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE REDIS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "redis" {
  source = "./modules/cache/aws/redis"

  cluster_name = "redis-production"
  node_type    = "cache.t2.small"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.persistence_subnets}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE MEMCACHED CLUSTER
# ---------------------------------------------------------------------------------------------------------------------


#module "memcached" {
#  source = "./modules/cache/aws/memcached"
#
#  cluster_id = "memcached-production"
#
#  vpc_id    = "${module.vpc.vpc_id}"
#  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"
#}
