# EFS Module

The EFS module creates an [Amazon Elastic File System](https://aws.amazon.com/efs/).
Amazon EFS provides simple, scalable, elastic file storage for use with AWS Cloud
services and on-premises resources. It is easy to use and offers a simple interface
that allows you to create and configure file systems quickly and easily. Amazon EFS
is built to elastically scale on demand without disrupting applications, growing and
shrinking automatically as you add and remove files, so your applications have the
storage they need, when they need it.

For more information please refer to the following AWS product page: https://aws.amazon.com/efs/.

We recommend you deploy the EFS filesystem in the persistence subnets created by our [VPC module](../../../network/aws/vpc/README.md).

## Usage

Sample module usage:

```
module "efs" {
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
