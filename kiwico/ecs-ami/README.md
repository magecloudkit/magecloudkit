# KiwiCo ECS AMI Packer Module

This module builds an AMI based on the Ubuntu 16.04 distribution with the
Amazon ECS agent installed. It is intended to run the applications and includes
drivers for mounting EFS volumes and enhanced networking.

The Brightfame module has been modified to launch EC2 instances in one of KiwiCo's
VPCs. We need to emulate this behaviour as KiwiCo has an old AWS account without
a default VPC.

## Usage

To build only the local image, simply run:

```bash
$ packer build -only=ubuntu-docker ecs.json
```

To build the AWS AMI, simply run:

```bash
$ packer build -only=ubuntu-ami ecs.json
```

The default region is `us-east-1`. If you wish to build an AMI for a different
region, simply pass in the `aws_region` parameter:

```bash
$ packer build -var aws_region=eu-west-1 -only ubuntu-ami ecs.json
```
