# Logs Module

The Logs module is used to create Amazon CloudWatch log group

Amazon CloudWatch is a monitoring and management service built for developers,
system operators, site reliability engineers (SRE), and IT managers. CloudWatch
provides you with data and actionable insights to monitor your applications,
understand and respond to system-wide performance changes, optimize resource
utilization, and get a unified view of operational health. CloudWatch collects
monitoring and operational data in the form of logs, metrics, and events,
providing you with a unified view of AWS resources, applications and services
that run on AWS, and on-premises servers. You can use CloudWatch to set high
resolution alarms, visualize logs and metrics side by side, take automated
actions, troubleshoot issues, and discover insights to optimize your
applications, and ensure they are running smoothly.

For more information please refer to the AWS article: https://aws.amazon.com/cloudwatch/

## Usage

```
module "logs" {
  source = "./modules/monitoring/aws/logs"

  name              = "production-app"
  retention_in_days = 30

  # An example of custom tags
  tags = [
    {
      Environment = "production"
    },
  ]
}
```
