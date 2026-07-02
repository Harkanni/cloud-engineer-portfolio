terraform {
  backend "s3" {
    bucket       = "akanni-terraform-backend"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
