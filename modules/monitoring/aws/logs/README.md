# Logs Module

The Logs module is used to create Amazon CloudWatch log group. CloudWatch log
groups are useful for streaming logs from containers running on an Amazon ECS cluster.

For more information please refer to the AWS product page: https://aws.amazon.com/cloudwatch/.

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

## Outputs

| Name | Description |
|------|-------------|
| log_group_id | The ARN of the created log group. |
