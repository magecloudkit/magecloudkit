output "magecloudkit_help" {
  value = <<EOF
-
------------------------------------------------------------------
The MageCloudKit AWS resources have now been successfully created!

You can SSH into the Bastion instance using:

$ ssh ubuntu@${module.bastion.public_ip} -p ${module.bastion.ssh_port}

The ALB load balancer is available at:

http://${module.alb.dns_name}
------------------------------------------------------------------
EOF
}

output "bastion_ip" {
  value = "${module.bastion.public_ip}"
}
