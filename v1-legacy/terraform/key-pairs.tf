resource "aws_key_pair" "deployer" {
  key_name   = "${terraform.workspace}-deployer"
  public_key = "${file("private/deployer.pub")}"
}
