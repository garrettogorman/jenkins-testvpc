terraform {
  backend "s3" {
    bucket = "terraform-state-garrett"
    key    = "jenkins-test"
    region = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
  }
}