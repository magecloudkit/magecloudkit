# ECS AMI Packer Module

This module builds an AMI based on the Ubuntu 16.04 distribution with the
Amazon ECS agent installed. It is intended to run the applications and includes
drivers for mounting EFS volumes and enhanced networking.

## Usage

To build only the local image, simply run:

```bash
$ packer build -only=ubuntu-docker ecs.json
```

To build the AWS AMI, simply run:

```bash
$ packer build -only=ubuntu-ami ecs.json
```
