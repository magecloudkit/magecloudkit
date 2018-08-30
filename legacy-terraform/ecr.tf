data "aws_ecr_repository" "magento2" {
  name = "magecloudkit/magento2"
}

data "aws_ecr_repository" "nginx" {
  name = "magecloudkit/nginx"
}

// Uncomment the following lines below to create an IAM user to be used
// with CircleCI for pushing Docker images


// An IAM user used for CircleCI to push Docker images
//resource "aws_iam_user" "circleci" {
//  name = "circleci"
//}


// Provides full access to Amazon EC2 Container Registry repositories,
// but does not allow repository deletion or policy changes.
//resource "aws_iam_policy_attachment" "circleci-iam-attach" {
//  name       = "circleci-policy-attachment"
//  users      = ["${aws_iam_user.circleci.name}"]
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
//}

