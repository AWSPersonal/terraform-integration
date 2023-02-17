terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "Dispatches-Module" {
  source  = "./modules/services"
  service = "dispatches"
}

resource "null_resource" "clean-up" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = join(" && ", [
      "rm -R build",
      "rm -R compressed"
    ])
  }
}