/* bastion/vpn server */
resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

resource "aws_instance" "bastion" {
  ami           = "${lookup(var.amis, var.aws_region)}"
  instance_type = "t2.micro"

  # deploy the instance into the first availability zone
  subnet_id = "${aws_subnet.public_az1.id}"

  # add security groups to allow ssh & vpn access
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  key_name          = "${aws_key_pair.deployer.key_name}"
  source_dest_check = false

  connection {
    user        = "ubuntu"
    private_key = "${file("private/deployer.pem")}"
  }

  # Copies the SSH keys
  provisioner "file" {
    source      = "ssh_keys"
    destination = "/tmp"
  }

  # provision the instance (we run openvpn using Docker)
  provisioner "remote-exec" {
    inline = [
      # provision ssh keys
      "cat /tmp/public/* >> /home/ubuntu/.ssh/authorized_keys",
      # update apt packages
      "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      # configure networking
      "sudo iptables -t nat -A POSTROUTING -j MASQUERADE",
      "echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward",
      # install Docker
      "curl -sSL https://get.docker.com/ | sudo sh",
      # init openvpn data container
      "sudo mkdir -p /etc/openvpn",
      "sudo docker run --name ovpn-data -v /etc/openvpn busybox",
      # generate openvpn server config
      "sudo docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -p ${var.vpc_cidr} -n ${var.amazon_dns_server} -u udp://${aws_instance.bastion.public_ip}",
    ]
  }

  # add tags
  tags {
    Name        = "${terraform.workspace}-bastion01"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "bastion" {
  name        = "sg_${terraform.workspace}_bastion"
  description = "Security group for bastion instances that allows SSH and VPN traffic from internet"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags {
    Name        = "sg-${terraform.workspace}-bastion"
    Environment = "${terraform.workspace}"
  }
}
