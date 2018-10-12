# ---------------------------------------------------------------------------------------------------------------------
# LOG MODULE
# This module allows you to setup logging using the CloudWatch Logs feature.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.0"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.name}"
  retention_in_days = "${var.retention_in_days}"

  # add tags
  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.name}"
    )
  )}"
}
