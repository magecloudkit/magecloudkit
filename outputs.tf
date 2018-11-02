output "magecloudkit_help" {
  value = <<EOF
-
------------------------------------------------------------------
The MageCloudKit AWS resources have now been successfully created!

You can SSH into the Bastion instance using:

$ ssh -A ubuntu@${module.bastion.public_ip} -p ${module.bastion.ssh_port}

The ALB load balancer is available at:

http://${module.alb.dns_name}

Jenkins is available at:

http://${module.alb_jenkins.dns_name}
------------------------------------------------------------------
EOF
}
