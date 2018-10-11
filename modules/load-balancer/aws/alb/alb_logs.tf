resource "aws_lb" "application" {
  load_balancer_type               = "application"
  name                             = "${var.name}"
  internal                         = "${var.load_balancer_is_internal}"
  security_groups                  = ["${var.security_groups}"]
  subnets                          = ["${var.subnet_ids}"]
  idle_timeout                     = "${var.idle_timeout}"
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.enable_deletion_protection}"
  enable_http2                     = "${var.enable_http2}"
  ip_address_type                  = "${var.ip_address_type}"
  tags                             = "${merge(var.tags, map("Name", var.name))}"

  access_logs {
    enabled = true
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
  }

  timeouts {
    create = "${var.load_balancer_create_timeout}"
    delete = "${var.load_balancer_delete_timeout}"
    update = "${var.load_balancer_update_timeout}"
  }

  count = "${var.logging_enabled ? 1 : 0}"
}

resource "aws_lb_target_group" "main" {
  name                 = "${lookup(var.target_groups[count.index], "name")}"
  vpc_id               = "${var.vpc_id}"
  port                 = "${lookup(var.target_groups[count.index], "backend_port")}"
  protocol             = "${upper(lookup(var.target_groups[count.index], "backend_protocol"))}"
  deregistration_delay = "${lookup(var.target_groups[count.index], "deregistration_delay", lookup(var.target_groups_defaults, "deregistration_delay"))}"
  target_type          = "${lookup(var.target_groups[count.index], "target_type", lookup(var.target_groups_defaults, "target_type"))}"

  health_check {
    interval            = "${lookup(var.target_groups[count.index], "health_check_interval", lookup(var.target_groups_defaults, "health_check_interval"))}"
    path                = "${lookup(var.target_groups[count.index], "health_check_path", lookup(var.target_groups_defaults, "health_check_path"))}"
    port                = "${lookup(var.target_groups[count.index], "health_check_port", lookup(var.target_groups_defaults, "health_check_port"))}"
    healthy_threshold   = "${lookup(var.target_groups[count.index], "health_check_healthy_threshold", lookup(var.target_groups_defaults, "health_check_healthy_threshold"))}"
    unhealthy_threshold = "${lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", lookup(var.target_groups_defaults, "health_check_unhealthy_threshold"))}"
    timeout             = "${lookup(var.target_groups[count.index], "health_check_timeout", lookup(var.target_groups_defaults, "health_check_timeout"))}"
    protocol            = "${upper(lookup(var.target_groups[count.index], "healthcheck_protocol", lookup(var.target_groups[count.index], "backend_protocol")))}"
    matcher             = "${lookup(var.target_groups[count.index], "health_check_matcher", lookup(var.target_groups_defaults, "health_check_matcher"))}"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${lookup(var.target_groups[count.index], "cookie_duration", lookup(var.target_groups_defaults, "cookie_duration"))}"
    enabled         = "${lookup(var.target_groups[count.index], "stickiness_enabled", lookup(var.target_groups_defaults, "stickiness_enabled"))}"
  }

  tags       = "${merge(var.tags, map("Name", lookup(var.target_groups[count.index], "name")))}"
  count      = "${var.logging_enabled ? var.target_groups_count : 0}"
  depends_on = ["aws_lb.application"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "frontend_http_tcp" {
  load_balancer_arn = "${element(concat(aws_lb.application.*.arn, aws_lb.application_no_logs.*.arn), 0)}"
  port              = "${lookup(var.http_tcp_listeners[count.index], "port")}"
  protocol          = "${lookup(var.http_tcp_listeners[count.index], "protocol")}"
  count             = "${var.logging_enabled ? var.http_tcp_listeners_count : 0}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.*.id[lookup(var.http_tcp_listeners[count.index], "target_group_index", 0)]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = "${element(concat(aws_lb.application.*.arn, aws_lb.application_no_logs.*.arn), 0)}"
  port              = "${lookup(var.https_listeners[count.index], "port")}"
  protocol          = "HTTPS"
  certificate_arn   = "${lookup(var.https_listeners[count.index], "certificate_arn")}"
  ssl_policy        = "${lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)}"
  count             = "${var.logging_enabled ? var.https_listeners_count : 0}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.*.id[lookup(var.https_listeners[count.index], "target_group_index", 0)]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https_listener" {
  listener_arn    = "${aws_lb_listener.frontend_https.*.arn[lookup(var.extra_ssl_certs[count.index], "https_listener_index")]}"
  certificate_arn = "${lookup(var.extra_ssl_certs[count.index], "certificate_arn")}"
  count           = "${var.logging_enabled ? var.extra_ssl_certs_count : 0}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET IF REQUIRED TO STORE THE ALB LOGS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "log_bucket" {
  count         = "${var.create_log_bucket}"
  bucket        = "${var.log_bucket_name}"
  policy        = "${data.aws_iam_policy_document.bucket_policy.json}"
  force_destroy = true
  tags          = "${var.tags}"

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "${var.log_bucket_expiry_in_days}"
    }
  }
}

# Data providers to assist with creating the log bucket and applying the appropriate IAM policies.
data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.log_bucket_name}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}
