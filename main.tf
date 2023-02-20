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

module "Shared" {
  source  = "./modules/shared"
  service = "shared"
}

module "Dispatches" {
  source           = "./modules/services"
  service          = "dispatches"
  role             = module.Authorization.role_arn_lambda
  policy           = module.Authorization.policy_arn
  function_name    = "psiog-${terraform.workspace}-lambda-dispatches"
  environment_conf = var.dispatches_conf
  layer_name       = module.Shared.layer_name
  depends_on = [
    module.Shared
  ]
}

module "Tags" {
  source           = "./modules/services"
  service          = "tags"
  role             = module.Authorization.role_arn_lambda
  policy           = module.Authorization.policy_arn
  function_name    = "psiog-${terraform.workspace}-tags"
  environment_conf = var.tags_conf
  layer_name       = module.Shared.layer_name
  depends_on = [
    module.Shared
  ]
}

module "API-Gateway" {
  source = "./modules/API"
  endpoints = {
    dispatches = {
      name          = module.Dispatches.function_name
      path          = "dispatches",
      invoke_arn    = module.Dispatches.invoke_arn
      function_name = module.Dispatches.function_name
      role          = module.Authorization.role_arn_apig
    },
    tags = {
      name          = module.Tags.function_name
      path          = "tags",
      invoke_arn    = module.Tags.invoke_arn
      function_name = module.Tags.function_name
      role          = module.Authorization.role_arn_apig
    },
  }
}

# resource "null_resource" "clean-up" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   depends_on = [
#     module.API-Gateway
#   ]
#   provisioner "local-exec" {
#     command = join(" && ", [
#       "rm -r build",
#     ])
#   }
# }
