# Memcached Module

The Memcached module can be used to deploy a ElastiCache Memcached cluster. It is particularly
useful for storing Magento session data as it supports locking.

ElastiCache is a fully managed Memcached service, making it easy to seamlessly deploy, run and
scale popular open source compatible in-memory data stores.

For more information, please refer to the AWS product documentation: https://docs.aws.amazon.com/elasticache/.

## Usage

```
module "memcached" {
  source = "./modules/cache/aws/memcached"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  cluster_id           = "memcached-prod-cluster"
  engine_version       = "1.4.24"
  node_type            = "cache.m3.large"
  port                 = 11211
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.4"
}
```
