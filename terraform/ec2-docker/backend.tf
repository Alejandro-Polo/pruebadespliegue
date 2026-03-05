terraform {
  backend "s3" {
    bucket = "terraform-tfstate-symfony"
    key    = "ec2-docker/terraform.tfstate"
    region = "us-east-1"
  }
}