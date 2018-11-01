# ---------------------------------------------------------------------------------------------------------------------
# WEB-SERVICE - ECS-SERVICE
#
# Create an ECS service for the web-service.
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_roles" {
  source       = "./modules/app-cluster/aws/ecs-roles"
  cluster_name = "${var.ecs_cluster_name_app}"
  prefix       = "${var.ecs_cluster_name_app}"
}

data "aws_ecs_task_definition" "web_service_task_definition" {
  task_definition = "${aws_ecs_task_definition.web_service_task_definition.family}"
  depends_on      = ["aws_ecs_task_definition.web_service_task_definition"]
}

module "ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  name                     = "web-service"
  cluster_arn              = "${module.app_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name_app}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[0]}"

  desired_task_count = 4
  task_definition    = "${aws_ecs_task_definition.web_service_task_definition.family}:${max(aws_ecs_task_definition.web_service_task_definition.revision,data.aws_ecs_task_definition.web_service_task_definition.revision)}"
  container_name     = "nginx"
  container_port     = "80"
}

resource "aws_ecs_task_definition" "web_service_task_definition" {
  family                = "${var.project_name}-web-service"
  task_role_arn         = "${module.ecs_roles.ecs_default_task_iam_role_arn}"
  container_definitions = "${data.template_file.ecs_web_task_container_definitions.rendered}"

  volume = {
    name      = "media"
    host_path = "/mnt/media/magento"
  }

  volume = {
    name      = "wordpress"
    host_path = "/mnt/media/wordpress"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE ECS CONTAINER DEFINITIONS FOR THE WEB SERVICE
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ecs_web_task_container_definitions" {
  template = "${file("./task-definitions/web-service.json")}"

  vars {
    environment                             = "${var.environment}"
    nginx_image                             = "054130723771.dkr.ecr.us-west-1.amazonaws.com/kiwico/nginx"
    magento_image                           = "054130723771.dkr.ecr.us-west-1.amazonaws.com/kiwico/magento"
    php_memory_limit                        = "768M"
    php_pm                                  = "dynamic"
    php_pm_max_children                     = "175"
    php_pm_start_servers                    = "10"
    php_pm_min_spare_servers                = "5"
    php_pm_max_spare_servers                = "15"
    php_pm_max_requests                     = "1000"
    cloudwatch_logs_group                   = "${module.ecs-cluster-logs.log_group_id}"
    cloudwatch_logs_region                  = "${var.aws_region}"
    cloudwatch_logs_nginx_stream_prefix     = "web/nginx"
    cloudwatch_logs_magento_stream_prefix   = "web/magento"
    cloudwatch_logs_blackfire_stream_prefix = "web/blackfire"
    mysql_host                              = "${aws_route53_record.db.fqdn}"
    mysql_database                          = "${var.env_mysql_database}"
    mysql_user                              = "${var.env_mysql_user}"
    mysql_password                          = "${var.env_mysql_password}"
    redis_cache_host                        = "${aws_route53_record.redis_cache.fqdn}"
    memcached_host                          = "${aws_route53_record.memcached.fqdn}"
    mage_table_prefix                       = "${var.env_mage_table_prefix}"
    blackfire_server_id                     = "${var.env_blackfire_server_id}"
    blackfire_server_token                  = "${var.env_blackfire_server_token}"
  }
}
