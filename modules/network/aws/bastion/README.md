# Bastion Host Module

The Bastion host module is used to create a bastion host.

Bastion hosts enable you to securely connect to resources inside an Amazon VPC without exposing them to the
Internet. After you set up your bastion hosts, you can access the other instances in your VPC through Secure
Shell (SSH) connections on Linux. Bastion hosts are also configured with security groups to provide
fine-grained ingress control.

For more information please refer to the AWS article: https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html.

## Usage

Sample module usage:

```
module "bastion" {
  source = "./modules/network/aws/bastion"

  instance_type = "t2.medium"

  user_data = "${data.template_file.user_data_bastion.rendered}"

  vpc_id    = "${data.aws_vpc.default.id}"
  subnet_id = "${element(data.aws_subnet_ids.default.ids, 0)}"

  # To make testing easier, we allow SSH requests from any IP address here. In a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  ssh_key_name = "example-keypair"

  # An example of custom tags
  tags = [
    {
      Environment = "development"
    },
  ]
}

data "template_file" "user_data_bastion" {
  template = "${file("./modules/network/aws/bastion/user-data/user-data.sh")}"

  vars {
    ssh_port = "${module.bastion.ssh_port}"
  }
}
```
