# ECS Service Module

The ECS Service Module deploys one or more Docker containers in a long-running ECS service. This module supports rolling deployments,
Auto Scaling and integration with the ALB Load Balancer module.

## Usage

```hcl
module "aws_ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  service_name = "web-service"
  subnet_ids   = "${module.vpc.private_subnets}"
  cluster      = "${module.ecs_cluster.cluster_name}"
  environment  = "production"

  task_definition = "${aws_ecs_task_definition.web_service.family}:${max("${aws_ecs_task_definition.web_service.revision}", "${data.aws_ecs_task_definition.web_service.revision}")}"
  desired_count   = 2
}

module "ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  name                     = "web-service"
  cluster_arn              = "${module.app_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name_app}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[0]}"

  task_definition = "${aws_ecs_task_definition.web_service_task_definition.family}:${max(aws_ecs_task_definition.web_service_task_definition.revision,data.aws_ecs_task_definition.web_service_task_definition.revision)}"
  container_name  = "nginx"
  container_port  = "80"

  desired_task_count = 2
}
```

Or to utilize ECS Auto Scaling:

```hcl
module "ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  name                     = "web-service"
  cluster_arn              = "${module.app_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name_app}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[0]}"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  task_definition = "${aws_ecs_task_definition.web_service_task_definition.family}:${max(aws_ecs_task_definition.web_service_task_definition.revision,data.aws_ecs_task_definition.web_service_task_definition.revision)}"
  container_name  = "nginx"
  container_port  = "80"

  # set autoscaling properties
  # https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html
  enable_autoscaling = true

  desired_task_count   = 4
  desired_min_capacity = 4
  desired_max_capacity = 12

  autoscaling_properties = [
    {
      type               = "CPUUtilization"
      direction          = "up"
      evaluation_periods = "2"
      observation_period = "300"
      statistic          = "Average"
      threshold          = "89"
      cooldown           = "900"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "1"
    },
    {
      type               = "CPUUtilization"
      direction          = "down"
      evaluation_periods = "4"
      observation_period = "300"
      statistic          = "Average"
      threshold          = "10"
      cooldown           = "300"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "-1"
    },
  ]
}
```
