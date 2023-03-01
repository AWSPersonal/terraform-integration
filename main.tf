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
    tags = {
      offering   = "Personal"
      Enviroment = terraform.workspace
      Terraform  = "True"
    }
  }
}

module "Github" {
  source          = "./modules/github"
  git_clone_url   = var.github_specs.clone_url
  git_branch      = var.github_specs.branch
  git_destination = "covalent-repo"
}

module "Authorization" {
  source = "./modules/authorization"
}

module "Shared" {
  source        = "./modules/shared"
  service       = "shared"
  source_folder = module.Github.git_destination
  region        = var.aws_region
  depends_on = [
    module.Github
  ]
}

module "Dispatches" {
  source           = "./modules/services"
  service          = "dispatches"
  role             = module.Authorization.role_arn_lambda
  policy           = module.Authorization.policy_arn
  function_name    = "psiog-${terraform.workspace}-lambda-dispatches"
  environment_conf = var.dispatches_conf
  layer_name       = module.Shared.layer_name
  region           = var.aws_region
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
  region           = var.aws_region
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

resource "null_resource" "clean-up" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    module.API-Gateway
  ]
  provisioner "local-exec" {
    command = join(" && ", [
      "rm -r build",
    ])
  }
}
