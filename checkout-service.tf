# ---------------------------------------------------------------------------------------------------------------------
# CHECKOUT-SERVICE - ECS-SERVICE
#
# Create an ECS service for the checkout-service.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ecs_task_definition" "checkout_service_task_definition" {
  task_definition = "${aws_ecs_task_definition.checkout_service_task_definition.family}"
  depends_on      = ["aws_ecs_task_definition.checkout_service_task_definition"]
}

module "ecs_checkout_service" {
  source = "./modules/app-cluster/aws/ecs-service"

  name                     = "checkout-service"
  cluster_arn              = "${module.checkout_cluster.cluster_arn}"
  cluster_name             = "${var.ecs_cluster_name_checkout}"
  ecs_service_iam_role_arn = "${aws_iam_role.ecs_lb_role.arn}"
  target_group_arn         = "${module.alb.target_group_arns[1]}"

  desired_task_count = 1
  task_definition    = "${aws_ecs_task_definition.checkout_service_task_definition.family}:${max(aws_ecs_task_definition.checkout_service_task_definition.revision,data.aws_ecs_task_definition.checkout_service_task_definition.revision)}"
  container_name     = "nginx"
  container_port     = "80"
}

resource "aws_ecs_task_definition" "checkout_service_task_definition" {
  family                = "${var.project_name}-checkout-service"
  task_role_arn         = "${module.ecs_roles.ecs_default_task_iam_role_arn}"
  container_definitions = "${data.template_file.ecs_checkout_task_container_definitions.rendered}"

  volume = {
    name      = "media"
    host_path = "/mnt/media"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE ECS CONTAINER DEFINITIONS FOR THE CHECKOUT SERVICE
#
# This script will configure the instances to join the specified ECS cluster.
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "ecs_checkout_task_container_definitions" {
  template = "${file("./task-definitions/checkout-service.json")}"

  vars {
    environment                             = "${var.environment}"
    nginx_image                             = "054130723771.dkr.ecr.us-west-1.amazonaws.com/kiwico/nginx"
    magento_image                           = "054130723771.dkr.ecr.us-west-1.amazonaws.com/kiwico/magento"
    cloudwatch_logs_group                   = "${module.ecs-cluster-logs-checkout.log_group_id}"
    cloudwatch_logs_region                  = "${var.aws_region}"
    cloudwatch_logs_nginx_stream_prefix     = "checkout/nginx"
    cloudwatch_logs_magento_stream_prefix   = "checkout/magento"
    cloudwatch_logs_blackfire_stream_prefix = "checkout/blackfire"
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

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE CUSTOM ALB RULES FOR THE CHECKOUT SERVICE
# ---------------------------------------------------------------------------------------------------------------------

# https
resource "aws_lb_listener_rule" "checkout_route_path_https" {
  listener_arn = "${module.alb.https_listener_arns[0]}"
  priority     = "20"

  action {
    type             = "forward"
    target_group_arn = "${module.alb.target_group_arns[1]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/checkout/*"]
  }

  lifecycle {
    ignore_changes = ["priority"]
  }
}

resource "aws_lb_listener_rule" "checkout3_route_path_https" {
  listener_arn = "${module.alb.https_listener_arns[0]}"
  priority     = "30"

  action {
    type             = "forward"
    target_group_arn = "${module.alb.target_group_arns[1]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/checkout3/*"]
  }

  lifecycle {
    ignore_changes = ["priority"]
  }
}

# http
resource "aws_lb_listener_rule" "checkout_route_path_http" {
  listener_arn = "${module.alb.http_tcp_listener_arns[0]}"
  priority     = "20"

  action {
    type             = "forward"
    target_group_arn = "${module.alb.target_group_arns[1]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/checkout/*"]
  }

  lifecycle {
    ignore_changes = ["priority"]
  }
}

resource "aws_lb_listener_rule" "checkout3_route_path_http" {
  listener_arn = "${module.alb.http_tcp_listener_arns[0]}"
  priority     = "30"

  action {
    type             = "forward"
    target_group_arn = "${module.alb.target_group_arns[1]}"
  }

  condition {
    field  = "path-pattern"
    values = ["/checkout3/*"]
  }

  lifecycle {
    ignore_changes = ["priority"]
  }
}
