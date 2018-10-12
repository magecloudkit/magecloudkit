# VPC Module

This module is used to create an [Amazon VPC](https://aws.amazon.com/vpc/) to house production resources. This
module creates a VPC, and both public and private subnets across all Availability zones, route tables, routing
rules, Internet gateways and NAT gateways.

It is inspired by a blog post written by Ben Whaley titled
"[A Reference VPC architecture](https://www.whaletech.co/2014/10/02/reference-vpc-architecture.html)."

## Usage

Sample module usage:

```
module "vpc" {
  source             = "./modules/network/aws/vpc"
  name               = "magecloudkit-default"
  region             = "eu-west-1"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  # An example of custom tags
  tags = [
    {
      Environment = "production"
    },
  ]
}
```
