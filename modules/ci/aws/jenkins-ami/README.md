# Jenkins AMI Module

The Jenkins AMI module can be used to build an Amazon AMI with the [Jenkins](https://jenkins.io/)
open source automation software installed. It is based on the Ubuntu 16.04 distribution. This module
requires [Packer](https://packer.io/) to build the included template and uses the
[install-jenkins](../install-jenkins/README.md) module.

We recommend that you use this module as an example, copy the included template and customize it
specifically for your own needs.

## Requirements

 * [Packer v0.12.0](https://packer.io/)
 * [Docker](https://www.docker.com/) for testing locally

## Usage

To build the AMI:

```bash
$ packer build -only=ubuntu-ami jenkins.json
```

You can also test the template, locally using Docker.

Build the Docker image for testing locally:

```bash
$ packer build -only=ubuntu-docker jenkins.json
```

And to run it:

```bash
$ OS_NAME=ubuntu-linux docker-compose up
```
