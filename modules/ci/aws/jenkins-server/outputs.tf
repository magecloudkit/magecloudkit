output "asg_name" {
  value = "${aws_autoscaling_group.autoscaling_group.name}"
}

output "cluster_size" {
  value = "${aws_autoscaling_group.autoscaling_group.desired_capacity}"
}

output "launch_config_name" {
  value = "${aws_launch_configuration.launch_configuration.name}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.instance_role.arn}"
}

output "iam_role_id" {
  value = "${aws_iam_role.instance_role.id}"
}

output "security_group_id" {
  value = "${aws_security_group.lc_security_group.id}"
}

output "http_port" {
  value = "${var.http_port}"
}

output "volume_mountpoint" {
  value = "${var.volume_mountpoint}"
}

output "volume_owner" {
  value = "${var.volume_owner}"
}

output "efs_filesystem_id" {
  value = "${module.efs.efs_filesystem_id}"
}

output "efs_dns_name" {
  value = "${module.efs.efs_dns_name}"
}

output "efs_security_group_id" {
  value = "${module.efs.security_group_id}"
}
