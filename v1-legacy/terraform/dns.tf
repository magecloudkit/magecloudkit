resource "aws_route53_zone" "internal" {
  name    = "${var.internal_domain}"
  vpc_id  = "${aws_vpc.default.id}"
  comment = "${terraform.workspace} zone"

  tags {
    Environment = "${terraform.workspace}"
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
  name    = "db.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_rds_cluster.default.endpoint}"]
}

resource "aws_route53_record" "redis_cache" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "redis-cache.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}"]
}

resource "aws_route53_record" "redis_session" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "redis-session.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elasticache_cluster.redis_session.cache_nodes.0.address}"]
}

resource "aws_route53_record" "efs_dns" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "media.efs.us-east-1.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_efs_file_system.media.id}.efs.us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "efs_az1" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "media.us-east-1a.efs.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["us-east-1a.${aws_efs_file_system.media.id}.efs.us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "efs_az2" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "media.us-east-1b.efs.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["us-east-1b.${aws_efs_file_system.media.id}.efs.us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "efs_az3" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "media.us-east-1c.efs.${var.internal_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["us-east-1c.${aws_efs_file_system.media.id}.efs.us-east-1.amazonaws.com"]
}
