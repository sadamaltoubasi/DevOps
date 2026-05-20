terraform {
  backend "s3" {
    bucket = "sadamterra"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}