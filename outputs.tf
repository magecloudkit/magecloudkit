// TODO - attach EIP
//output "jenkins_ui_url" {
//  value = "${module.jenkins.}"
//}

output "jenkins_server_asg_name" {
  value = "${module.jenkins.asg_name}"
}
