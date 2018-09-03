# Jenkins AMI

This module builds an AMI based on the Ubuntu 16.04 distribution with the
Jenkins software installed.

## Usage

Build the Docker image for testing locally:

```bash
$ packer build -only=ubuntu-docker jenkins.json
```

And to run it:

```bash
$ OS_NAME=amazon-linux docker-compose up
```
