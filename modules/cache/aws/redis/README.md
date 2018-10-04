# REDIS Module

The REDIS module is used to create ElastiCache Redis instance.

ElastiCache offers fully managed Redis. Seamlessly deploy, run, and scale
popular open source compatible in-memory data stores. Build data-intensive apps
or improve the performance of your existing apps by retrieving data from high
throughput and low latency in-memory data stores Elastic Caches are also
configured with security groups to provide fine-grained ingress control.

For more information please refer to the AWS article: https://docs.aws.amazon.com/elasticache/

## Usage

```
module "redis" {
  source = "./modules/cache/aws/redis"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  cluster_id           = "redis-prod-cluster"
  engine_version       = "3.2.4"
  node_type            = "cache.t2.small"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
}
```
