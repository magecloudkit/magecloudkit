# Monitoring

## Metrics

## Alerts

## Exceptions & Errors

adsadsasd Bugsnag.

## Logs

The application logs are stored and indexed using the AWS CloudWatch Logs product. Each application container is configured to
use a separate CloudWatch log stream. The logs are stored for a maximum of 30 days. This setting is configurable in the
Terraform configuration code.

### Using the awslogs utility

The [awslogs][1] utility is more powerful that the CloudWatch Logs web interface, but must be run from the command line. You can
easily tail a log group or stream with the following command:

```bash
$ awslogs get production-app -w
```

For a full list of commands review the output of the help command:

```bash
$ awslogs --help
```

[1]: https://github.com/jorgebastida/awslogs
