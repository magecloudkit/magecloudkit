# MEMCACHED Module

The MEMCACHED module is used to create ElastiCache Memcached instance.

ElastiCache offers fully managed Memcached. Seamlessly deploy, run, and scale
popular open source compatible in-memory data stores. Build data-intensive apps
or improve the performance of your existing apps by retrieving data from high
throughput and low latency in-memory data stores Elastic Caches are also
configured with security groups to provide fine-grained ingress control.

For more information please refer to the AWS article: https://docs.aws.amazon.com/elasticache/

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
