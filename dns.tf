resource "aws_route53_zone" "internal" {
  name    = "${var.internal_domain}"
  vpc_id  = "${module.vpc.vpc_id}"
  comment = "${var.environment} zone"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "internal_ns" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "${var.internal_domain}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.internal.name_servers.0}",
    "${aws_route53_zone.internal.name_servers.1}",
    "${aws_route53_zone.internal.name_servers.2}",
    "${aws_route53_zone.internal.name_servers.3}",
  ]
}

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "db.${var.aws_region}.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.aurora.endpoint}"]
}

resource "aws_route53_record" "redis_cache" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "redis-cache.${var.aws_region}.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.redis.primary_address}"]
}

resource "aws_route53_record" "redis_session" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "redis-session.${var.aws_region}.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.redis_session.primary_address}"]
}

resource "aws_route53_record" "efs_dns" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "media.efs.${var.aws_region}.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.efs.efs_filesystem_id}.efs.us-west-1.amazonaws.com"]
}
