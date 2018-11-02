output "magecloudkit_help" {
  value = <<EOF
-
------------------------------------------------------------------
The MageCloudKit AWS resources have now been successfully created!

You can SSH into the Bastion instance using:

$ ssh ubuntu@${module.bastion.public_ip} -p ${module.bastion.ssh_port}
------------------------------------------------------------------
EOF
}

output "bastion_ip" {
  value = "${module.bastion.public_ip}"
}
