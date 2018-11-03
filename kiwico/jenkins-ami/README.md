# KiwiCo Jenkins AMI

This module builds an Ubuntu 16.04 AMI with the Jenkins software installed.

It has been customized by Brightfame, specifically for KiwiCo.


## Getting Started

To build the AMI:

```bash
$ packer build -only=ubuntu-ami jenkins.json
```

Build the Docker image for testing locally:

```bash
$ packer build -only=ubuntu-docker jenkins.json
```

And to run it:

```bash
$ OS_NAME=ubuntu-linux docker-compose up
```

## Deploying

1. Simply add the AMI ID from Packer to the `variables.tf` file. We are using the `jenkins_ami` variable.
2. Then run Terraform to recreate the Autoscaling group.
