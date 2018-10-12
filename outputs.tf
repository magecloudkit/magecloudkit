// TODO - attach EIP
//output "jenkins_ui_url" {
//  value = "${module.jenkins.}"
//}
#output "jenkins_server_asg_name" {
#  value = "${module.jenkins.asg_name}"
#}

output "magecloudkit_help" {
  value = <<EOF
-
------------------------------------------------------------------
The MageCloudKit AWS resources have now been successfully created!

You can SSH into the Bastion instance using:

$ ssh -A ubuntu@${module.bastion.public_ip} -p ${module.bastion.ssh_port}

The ALB load balancer is available at:

http://${module.alb.dns_name}
------------------------------------------------------------------
EOF
}
