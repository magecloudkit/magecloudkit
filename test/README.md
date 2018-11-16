# MageCloudKit Tests

This directory contains automated tests for MageCloudKit. Most of these tests are written in [Go](https://golang.org/) and use a helper library called [Terratest](https://github.com/gruntwork-io/terratest).

## WARNING

1. Many of these tests create real resources in an AWS account and try to clean those resources up at the
end of a test run. This means they may cost money to run and could potentially destroy production
infrastructure unintentionally. Therefore we recommend you do not run these tests in an AWS account
with production infrastructure.
2. Never forcefully shut the tests down (e.g. by hitting `CTRL + C`) or the cleanup tasks won't run!
3. We set `-timeout 60m` on all tests not because they necessarily take that long, but because Go has a default test timeout of 10 minutes, after which it forcefully kills the tests with a `SIGQUIT`, preventing the cleanup
tasks from running. Therefore, we set an overlying long timeout to make sure all tests have enough time to finish and clean up.

## Running the tests

### Prerequisites

- Install the latest version of [Go](https://golang.org/).
- Install [dep](https://github.com/golang/dep) for Go dependency management.
- Install [Terraform](https://www.terraform.io/downloads.html).
- Configure your AWS credentials using one of the [options supported by the AWS 
  SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). Usually, the easiest option is to set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

### One-time setup

Download Go dependencies using dep:

```
cd test
dep ensure
```

### Run tests

```bash
cd test
go test -v -timeout 60m
```

### Run a specific test

To run a specific test called `TestFoo`:

```bash
cd test
go test -v -timeout 60m -run TestFoo
```
