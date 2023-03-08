data "aws_caller_identity" "current" {
  lifecycle {
    precondition {
      condition     = terraform.workspace != "default"
      error_message = "Your environment is default. Please choose either dev or qa. You can switch your environment using terraform workspace select {workspace_name}"
    }
    postcondition {
      condition     = self.account_id == var.allowed_account_ids[0]
      error_message = "Invalid deployment configuration"
    }
  }
}

provider "aws" {
  region = var.aws_region

  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = var.tags
  }
}

# Clone the B2C source code from the github repository
module "Github" {
  source          = "./modules/github"
  git_clone_url   = var.github_specs.clone_url
  git_branch      = var.github_specs.branch
  git_destination = "covalent-b2c"
}

# Create required IAM roles and policies for attaching for the below resources
module "Authorization" {
  source = "./modules/authorization"
}

# Deploy Shared Layer
module "Shared" {
  source        = "./modules/shared"
  service       = "shared"
  source_folder = module.Github.git_destination
  region        = var.aws_region
  depends_on = [
    module.Github
  ]
}

# Deploy Lambda Services
module "Lambda-Services" {
  for_each         = { for service in local.services : service.service_name => service }
  source           = "./modules/services"
  service          = each.value.service_name
  lambda_role      = module.Authorization.role_arn_lambda
  policy           = module.Authorization.policy_arn
  function_name    = each.value.function_name
  timeout          = each.value.timeout
  memory           = each.value.memory
  environment_conf = each.value.environment_conf
  layer_name       = module.Shared.layer_name
  region           = var.aws_region
  source_folder    = module.Github.git_destination
  depends_on = [
    module.Shared, module.Authorization
  ]
}

# Deploy Dynamo DB
# module "DynamoDB" {
#   source         = "./modules/dynamodb"
#   table_name     = "Activity-Tracker"
#   billing_mode   = "PAY_PER_REQUEST"
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "owner_id"
#   range_key      = "_id"
# }
output chumma{
  value = {for key, instance in module.Lambda-Services : key => instance.available_services}
}
# Deploy "API Gateway" and integrate with above services
# module "API-Gateway" {
#   source    = "./modules/api"
#   endpoints = {for key, instance in module.Lambda-Services : key => instance.available_services}
# }
# endpoints = {
#   dispatches = {
#     name          = module.Dispatches.function_name
#     path          = "dispatches",
#     invoke_arn    = module.Dispatches.invoke_arn
#     function_name = module.Dispatches.function_name
#     role          = module.Authorization.role_arn_apig
#     prefix_url    = "api/v1/dispatches"
#   },
#   tags = {
#     name          = module.Tags.function_name
#     path          = "tags",
#     invoke_arn    = module.Tags.invoke_arn
#     function_name = module.Tags.function_name
#     role          = module.Authorization.role_arn_apig
#     prefix_url    = "api/v1/tags"
#   },
# }

# resource "null_resource" "update_environment_variables" {
#   for_each = [module.Dispatches, module.Tags]
#   dynamic "local_exec" {
#     for_each = [module.Dispatches, module.Tags]
#     content {
#       command = "aws ${local_exec.value.service_name}"
#     }
#   }
# }

# module "Client-Amplify" {
#   source           = "./modules/amplify"
#   name             = "Client"
#   stage            = "PRODUCTION"
#   access_token     = var.github_specs.access_token
#   repository       = var.github_specs.repository
#   framework        = "REACT"
#   branch           = var.github_specs.branch
#   environment_name = "staging"
# }

# module "Admin-Amplify" {
#   source           = "./modules/amplify"
#   name             = "Admin"
#   stage            = "PRODUCTION"
#   access_token     = var.github_specs.access_token
#   repository       = var.github_specs.repository
#   framework        = "REACT"
#   branch           = var.github_specs.branch
#   environment_name = "staging"
# }

# module "Client-Cognito" {
#   source      = "./modules/cognito"
#   name        = "Covalent-SAAS-${terraform.workspace}-general"
#   client_name = "Covalent-SAAS-Client"
#   schema      = var.cognito_schema
#   domain_name = "covalent-saas"
# }

# module "Admin-Cognito" {
#   source      = "./modules/cognito"
#   name        = "Covalent-SAAS-${terraform.workspace}-admin"
#   client_name = "Covalent-SAAS-Client"
#   schema      = var.cognito_schema
#   domain_name = "covalent-saas"
# }

# Clean up once the above processes are done
resource "null_resource" "clean-up" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    module.Lambda-Services
  ]
  provisioner "local-exec" {
    command = join(" && ", [
      "rm -f -R build",
      "rm -f -R *-repo",
    ])
  }
}
