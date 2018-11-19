# Redis Module

The Redis module can be used to deploy a ElastiCache Redis cluster. It is particularly
useful for storing Magento cache data and acting as a backend for queue related use cases.

ElastiCache is a fully managed Memcached service, making it easy to seamlessly deploy, run and
scale popular open source compatible in-memory data stores.

For more information, please refer to the AWS product documentation: https://docs.aws.amazon.com/elasticache/.

## Usage

```
module "redis" {
  source = "./modules/cache/aws/redis"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  cluster_id           = "redis-production-cluster"
  engine_version       = "3.2.4"
  node_type            = "cache.t2.small"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
}
```
