resource "aws_cognito_user_pool" "pool" {
  name             = var.name
  alias_attributes = ["email", "preferred_username"]
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    required                 = true
  }

  schema {
    name                     = "given_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    required                 = true
  }

  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    required                 = true
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    required                 = true
  }

  schema {
    name                     = "organisation"
    attribute_data_type      = "String"
    developer_only_attribute = true
    required                 = false
    mutable                  = true
  }

  schema {
    name                     = "promotion"
    attribute_data_type      = "String"
    developer_only_attribute = true
    required                 = false
    mutable                  = true
  }
}

resource "aws_cognito_identity_provider" "identity_provider" {
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    authorize_scopes = "profile email openid"
    client_id        = "your client_id"
    client_secret    = "your client_secret"
  }
  attribute_mapping = {
    email       = "email"
    family_name = "family_name"
    given_name  = "given_name"
    name        = "name"
    username    = "sub"
  }

}

resource "aws_cognito_user_pool_client" "pool_client" {
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.pool.id
}
