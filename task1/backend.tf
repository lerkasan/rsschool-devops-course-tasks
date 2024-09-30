terraform {
  backend "s3" {
    bucket  = "terraform-state-bootstrap-rs-school-dev"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}