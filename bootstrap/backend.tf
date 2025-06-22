terraform {
  backend "s3" {
    bucket       = "terraform-state-bootstrap-rs-school-devops"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}