# ALB Load Balancer Module

This module allows you to deploy an Amazon ALB load balancer inside an Amazon VPC. We
recommend you deploy load balancers inside the public subnets created by our [VPC module](../../../network/aws/vpc/README.md).

This module is based on the Terraform community module available here: 
https://github.com/terraform-aws-modules/terraform-aws-alb.

## Usage

Sample module usage:

```
module "alb" {
  source                        = "./modules/load-balancer/aws/alb"
  load_balancer_name            = "my-alb"
  security_groups               = ["sg-edcd9784", "sg-edcd9785"]
  log_bucket_name               = "logs-us-east-2-123456789012"
  log_location_prefix           = "my-alb-logs"
  subnets                       = ["subnet-abcde012", "subnet-bcde012a"]
  tags                          = "${map("Environment", "test")}"
  vpc_id                        = "vpc-abcde012"
  https_listeners               = "${list(map("certificate_arn", "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012", "port", 443))}"
  https_listeners_count         = "1"
  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(map("name", "foo", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count           = "1"
}
```
