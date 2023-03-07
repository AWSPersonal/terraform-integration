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

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  auto_verified_attributes = ["email"]

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  dynamic "schema"{
    for_each = var.schema
    content{
      name = schema.value.name
      attribute_data_type = schema.value.data_type
      developer_only_attribute = schema.value.developer_only
      required = schema.value.required
      mutable =  schema.value.mutable
    }
  }
}