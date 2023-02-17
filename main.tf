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

module "Authorization" {
  source = "./modules/authorization"
}

module "Dispatches" {
  source           = "./modules/services"
  service          = "dispatches"
  role             = module.Authorization.role_arn
  policy           = module.Authorization.policy_arn
  function_name    = "psiog-${terraform.workspace}-lambda-dispatches"
  environment_conf = var.dispatches_conf
}

module "Tags" {
  source           = "./modules/services"
  service          = "tags"
  role             = module.Authorization.role_arn
  policy           = module.Authorization.policy_arn
  function_name    = "psiog-${terraform.workspace}-tags"
  environment_conf = var.tags_conf
}

resource "null_resource" "clean-up" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    module.Dispatches
  ]
  provisioner "local-exec" {
    command = join(" && ", [
      "rm -r build",
    ])
  }
}