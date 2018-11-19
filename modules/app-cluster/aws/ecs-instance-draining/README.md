# ECS Instance Draining Module

This module deploys a lambda function for automating container instance draining during a scaling event.
It is based on the blog post described here: https://aws.amazon.com/blogs/compute/how-to-automate-container-instance-draining-in-amazon-ecs/.

## Usage

```hcl
module "ecs_draining" {
  source = "./modules/app-cluster/aws/ecs-instance-draining"
  name   = "production-app"
}
```

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_arn | The ARN of the created Lambda function |
