# ECS Cluster Module

This module creates an ECS cluster.

Features:

 * Autoscaling Group for Rolling Deployments
 * CloudWatch Logs integration

## Usage

Sample module usage:

```
module "ecs_cluster" {
  source = "./modules/storage/aws/efs"

  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = "${var.availability_zones}"
  subnet_ids         = "${module.vpc.persistence_subnets}"

  allow_inbound_from_cidr_blocks = ["0.0.0.0/0"]
  allow_inbound_from_security_groups = []

  # An example of custom tags
  tags = [
    {
      Environment = "production"
    },
  ]
}
```
