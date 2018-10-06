# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A BASTION NODE
# ---------------------------------------------------------------------------------------------------------------------

module "bastion" {
  source = "../../modules/network/aws/bastion"

  instance_type = "t2.medium"

  user_data = "${data.template_cloudinit_config.user_data_bastion.rendered}"

  vpc_id    = "${module.vpc.vpc_id}"
  subnet_id = "${module.vpc.public_subnets[0]}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  key_pair_name = "${var.key_pair_name}"

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN ELASTIC IP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "bastion" {
  instance = "${module.bastion.instance_id}"
  vpc      = true

  #depends_on = ["aws_instance.instance"]

  # Workaround for an eventual consistency bug where Terraform doesn't wait long enough for an EIP to be created, which
  # can occasionally cause an 'Failure associating EIP: InvalidAllocationID.NotFound: The allocation ID 'eipalloc-XXX'
  # does not exist' error. For more info, see: https://github.com/hashicorp/terraform/issues/1815
  #provisioner "local-exec" {
  #  command = "echo 'Sleeping 15 seconds to work around EIP propagation bug in Terraform' && sleep 15"
  #}
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON THE BASTION INSTANCE WHEN IT'S BOOTING
#
# This script will configure the Bastion instance.
# ---------------------------------------------------------------------------------------------------------------------

data "template_cloudinit_config" "user_data_bastion" {
  gzip          = true
  base64_encode = true

  # get common user_data
  part {
    filename     = "user-data.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.user_data_bastion.rendered}"
  }

  # auto update script
  part {
    filename     = "auto-update.sh"
    content_type = "text/x-shellscript"
    content      = "${file("../../modules/security/auto-update/install.sh")}"
  }

  # fail2ban script
  part {
    filename     = "fail2ban.sh"
    content_type = "text/x-shellscript"
    content      = "${file("../../modules/security/fail2ban/install.sh")}"
  }
}

data "template_file" "user_data_bastion" {
  template = "${file("../../modules/network/aws/bastion/user-data/user-data.sh")}"

  vars {
    ssh_port = "${module.bastion.ssh_port}"
  }
}
