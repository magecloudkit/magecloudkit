# Jenkins AMI

This module builds an AMI based on the Ubuntu 16.04 distribution with the
Jenkins software installed.

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
