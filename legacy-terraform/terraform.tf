terraform {
  backend "s3" {
    bucket = "magecloudkit-state"
    key    = "terraform"
    region = "us-east-1"
  }
}
