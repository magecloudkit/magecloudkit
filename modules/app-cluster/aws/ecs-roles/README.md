# ECS Roles Module

The ECS Roles Module creates default IAM roles the ECS tasks can assume.

## Usage

```hcl
module "ecs_roles" {
  source       = "./modules/app-cluster/aws/ecs-roles"
  cluster_name = "production-app"
  prefix       = "production-app"
}
```

## Outputs

| Name | Description |
|------|-------------|
| ecs_default_task_iam_role_arn | The ARN of the default task IAM role created. |
