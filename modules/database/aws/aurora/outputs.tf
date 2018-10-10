output "db_rds_cluster" {
  value = "${aws_rds_cluster.default.id}"
}

output "db_rds_cluster_instances" {
  value = "${aws_rds_cluster_instance.cluster_instances.*.id}"
}

output "security_group_id" {
  value = "${aws_security_group.rds.id}"
}
