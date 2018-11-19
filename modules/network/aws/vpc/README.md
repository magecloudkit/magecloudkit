# VPC Module

The VPC module is used to create an [Amazon VPC](https://aws.amazon.com/vpc/) to contain production resources. This
module creates a VPC, public, private and persistence subnets across all availability zones, route tables, routing
rules, Internet gateways and NAT gateways. It is inspired by a blog post written by Ben Whaley titled
"[A Reference VPC architecture](https://www.whaletech.co/2014/10/02/reference-vpc-architecture.html)".

## Usage

Sample module usage:

```hcl
module "vpc" {
  source             = "./modules/network/aws/vpc"
  name               = "magecloudkit-production"
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
