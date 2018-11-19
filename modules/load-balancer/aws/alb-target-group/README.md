# ALB Target Group Module

This module allows you to create an ALB target group for use with an ALB
load balancer.

## Usage

Sample module usage:

```hcl
module "alb-target-group" {
  source                          = "./modules/load-balancer/aws/alb-target-group"
  target_group_name               = "Example"
  asg_name                        = "${var.asg_name}
  port                            = "${var.port}"
  listener_arns                   = "${module.alb.http_tcp_listener_arns[0]}"
  num_listener_arns               = "1"
  listener_rule_starting_priority = "10"
  health_check_path               = "/"
  vpc_id                          = "vpc-abcde012"
}
```
