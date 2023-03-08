variable "name" {
  type        = string
  default     = "covalent-app"
  description = "Name used to prefix aws resources"
}

variable "aws_region" {
  type        = string
  description = "Region in which Covalent server is deployed"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment name"
}

variable "covalent_commit_sha" {
  type        = string
  default     = "9bbf203da025ee76790009dcd36fabac51792731"
  description = "Covalent version"
}

variable "dispatches_conf" {
  type = map(any)
}

variable "tags_conf" {
  type = map(any)
}

variable "allowed_account_ids" {
  type = list(string)
}

variable "github_specs" {
  type = object({
    access_token = string
    repository   = string
    clone_url    = string
    branch       = string
  })
}

variable "tags" {
  type = map(string)
  default = {
    Offering : "Covalent SAAS",
    Team : "Psi",
    Environment : "int"
    Terraform : true
  }
}

variable "cognito_schema" {
  type = list(map(string))
  default = [{
    name           = "name"
    data_type      = "String"
    developer_only = false
    required       = true
    mutable        = false
    },
    {
      name           = "given_name"
      data_type      = "String"
      developer_only = false
      required       = true,
      mutable        = false
    },
    {
      name           = "family_name"
      data_type      = "String"
      developer_only = false
      required       = true,
      mutable        = false
    },
    {
      name           = "email"
      data_type      = "String"
      developer_only = false
      required       = true,
      mutable        = false
    },
    {
      name           = "organisation"
      data_type      = "String"
      developer_only = true
      required       = false
      mutable        = true
    },
    {
      name           = "promotion"
      data_type      = "String"
      developer_only = true
      required       = false
      mutable        = true
    }
  ]
}

locals {
  services = [
    {
      service_name     = "dispatches",
      timeout          = 6,
      memory           = 2000,
      function_name    = "psiog-${terraform.workspace}-lambda-dispatches",
      environment_conf = "${var.dispatches_conf}",
    },
    {
      service_name     = "tags",
      timeout          = 3,
      memory           = 1024,
      function_name    = "psiog-${terraform.workspace}-lambda-tags",
      environment_conf = "${var.tags_conf}",
    }
  ]
}
