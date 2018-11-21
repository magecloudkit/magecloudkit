# ---------------------------------------------------------------------------------------------------------------------
# WEB-SERVICE - ECS-SERVICE
#
# Create an ECS service for the web-service.
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_roles" {
  source = "../../modules/app-cluster/aws/ecs-roles"

  cluster_name = "${var.ecs_cluster_name}"
  prefix       = "${var.ecs_cluster_name}"
}

data "aws_ecs_task_definition" "app_service_task_definition" {
  task_definition = "${aws_ecs_task_definition.app_service_task_definition.family}"
  depends_on      = ["aws_ecs_task_definition.app_service_task_definition"]
}

module "ecs_app_service" {
  source = "../../modules/app-cluster/aws/ecs-service"

  name                     = "app-service"
  cluster_arn              = "${module.app_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[0]}"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  task_definition = "${aws_ecs_task_definition.app_service_task_definition.family}:${max(aws_ecs_task_definition.app_service_task_definition.revision,data.aws_ecs_task_definition.app_service_task_definition.revision)}"
  container_name  = "nginx"
  container_port  = "80"

  desired_task_count   = 2
  desired_min_capacity = 2
  desired_max_capacity = 4
}

resource "aws_ecs_task_definition" "app_service_task_definition" {
  family                = "${var.project_name}-app-service"
  task_role_arn         = "${module.ecs_roles.ecs_default_task_iam_role_arn}"
  container_definitions = "${data.template_file.ecs_app_task_container_definitions.rendered}"

  volume = {
    name      = "media"
    host_path = "/mnt/media/magento"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE ECS CONTAINER DEFINITIONS FOR THE APP SERVICE
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ecs_app_task_container_definitions" {
  template = "${file("./task-definitions/app-service.json")}"

  vars {
    environment                   = "${var.environment}"
    nginx_image                   = "magecloudkit/nginx:latest"
    magento_image                 = "magecloudkit/magento2:latest"
    php_memory_limit              = "768M"
    php_pm                        = "dynamic"
    php_pm_max_children           = "25"
    php_pm_start_servers          = "10"
    php_pm_min_spare_servers      = "10"
    php_pm_max_spare_servers      = "15"
    php_pm_max_requests           = "1000"
    cloudwatch_logs_group         = "${module.ecs-cluster-logs.log_group_id}"
    cloudwatch_logs_region        = "${var.aws_region}"
    cloudwatch_logs_stream_prefix = "web"
    mysql_host                    = "${var.env_mysql_host}"
    mysql_database                = "${var.env_mysql_database}"
    mysql_user                    = "${var.env_mysql_user}"
    mysql_password                = "${var.env_mysql_password}"
    redis_cache_host              = "${aws_route53_record.redis_cache.fqdn}"
    redis_session_host            = "${aws_route53_record.redis_session.fqdn}"
    mage_table_prefix             = "${var.env_mage_table_prefix}"
  }
}
