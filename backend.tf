terraform {
  backend "s3" {
    bucket = "covalent-b2c"
    key    = "terraform/all-state/terraform.tfstate"
    region = "ap-south-1"
  }
}