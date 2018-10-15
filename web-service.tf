# ---------------------------------------------------------------------------------------------------------------------
# WEB-SERVICE - ECS-SERVICE
#
# This module will create an ecs-service for web-service.
# ---------------------------------------------------------------------------------------------------------------------

module "ecs_roles" {
  source       = "./modules/app-cluster/aws/ecs-roles"
  cluster_name = "${var.ecs_cluster_name}"
  prefix       = "${var.ecs_cluster_name}"
}

data "aws_ecs_task_definition" "web_service_task_definition" {
  task_definition = "${aws_ecs_task_definition.web_service_task_definition.family}"
  depends_on      = ["aws_ecs_task_definition.web_service_task_definition"]
}

module "ecs_web_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  name                     = "web-service"
  cluster_arn              = "${module.app_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[0]}"

  desired_task_count = 2
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
    host_path = "/mnt/media"
  }
}

# Add custom routing rules for the foo service
#resource "aws_alb_listener_rule" "http_host_rule" {
#  listener_arn = "${lookup(data.terraform_remote_state.alb.listener_arns, 80)}"
#  priority     = 100
#
#  action {
#    type             = "forward"
#    target_group_arn = "${module.service.target_group_arn}"
#  }
#
# Note how I'm using host-based routing here. You may want to make the domain name a variable so you can customize it for each environment
#  condition {
#    field  = "host-header"
#    values = ["foo.acme.com"]
#  }
#}

# ---------------------------------------------------------------------------------------------------------------------
# THE ECS CONTAINER DEFINITIONS FOR THE WEB SERVICE
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ecs_web_task_container_definitions" {
  template = "${file("./task-definitions/web-service.json")}"

  vars {
    environment                           = "${var.environment}"
    nginx_image                           = "857346137638.dkr.ecr.us-west-1.amazonaws.com/brightfame/nginx"
    magento_image                         = "857346137638.dkr.ecr.us-west-1.amazonaws.com/brightfame/magento"
    cloudwatch_logs_group                 = "${module.ecs-cluster-logs.log_group_id}"
    cloudwatch_logs_region                = "${var.aws_region}"
    cloudwatch_logs_nginx_stream_prefix   = "web/nginx"
    cloudwatch_logs_magento_stream_prefix = "web/magento"
    mysql_host                            = "db.magecloudkit.internal"
    mysql_database                        = "magento"
    mysql_user                            = "magento"
    mysql_password                        = "magento"
    redis_cache_host                      = "redis.magecloudkit.internal"

    #mysql_host     = "${aws_route53_record.db.fqdn}"
    #mysql_database = "${var.env_mysql_database}"
    #mysql_user     = "${var.env_mysql_user}"
    #mysql_password = "${lookup(var.rds_password, terraform.workspace)}"
  }
}
