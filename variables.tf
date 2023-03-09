# Variables used for initalizing AWS resources and terraform
variable "aws_region" {
  type        = string
  description = "Region in which Covalent server is deployed"
}

variable "allowed_account_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

# Variables used for Amplify module
variable "amplify_sources" {
  type = list(object({
    name             = string
    stage            = string
    framework        = string
    environment_name = string
  }))
}

# Variables used for API-Gateway module
variable "endpoint_name" {
  type = string
}

variable "endpoint_type" {
  type = list(string)
}

# Variables used for Authorization module

# Variables used for Cognito module
variable "cognito_sources" {
  type = list(object({
    user_pool_name = string
    client_name    = string
    domain_name    = string
    attribute_schema = list(object({
      name           = string
      data_type      = string
      developer_only = string
      required       = string
      mutable        = string
    }))
  }))
}

# Variables used for DynamoDB module
variable "dynamodb_name" {
  type = string
}

variable "billing_mode" {
  type = string
}

variable "read_capacity" {
  type = number
}

variable "write_capacity" {
  type = number
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type = string
}

# Variables used for Github module
variable "github_specs" {
  type = object({
    access_token = string
    repository   = string
    clone_url    = string
    branch       = string
  })
}

# Variables used for Lambda module
variable "lambda_sources" {
  type = list(object({
    folder_name   = string
    service_name  = string
    timeout       = string
    memory        = string
    function_name = string
    environment_conf = object(
      {
        db_name                           = string
        db_password                       = string
        db_url                            = string
        db_username                       = string
        dispatch_organization_service_url = string
        dispatch_overview_service_url     = string
        dispatch_service_url              = string
        resource_path                     = string
        stage_path                        = string
      }
    )
  }))
}
