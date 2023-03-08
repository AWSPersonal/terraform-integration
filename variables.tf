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
  type = map(string)
}

# Variables used for API-Gateway module

# Variables used for Authorization module

# Variables used for Cognito module
variable "cognito_sources" {
  type = map(string)
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

variable "dynamodb_name" {
  type = string
}

variable "dynamodb_name" {
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
  type = list(map({
    service_name     = string
    timeout          = string
    memory           = string
    function_name    = string
    environment_conf = string
  }))
}
