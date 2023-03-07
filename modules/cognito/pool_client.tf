resource "aws_cognito_user_pool_client" "pool_client" {
  depends_on = [
    aws_cognito_user_pool.pool,
    aws_cognito_identity_provider.identity_provider
  ]
  name                          = var.client_name
  user_pool_id                  = aws_cognito_user_pool.pool.id
  explicit_auth_flows           = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  auth_session_validity         = 3
  refresh_token_validity        = 30
  access_token_validity         = 1
  id_token_validity             = 1
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"
  callback_urls                 = ["http://localhost:8080/projects"]
  logout_urls                   = ["http://localhost:8080/"]
  supported_identity_providers  = ["COGNITO", aws_cognito_identity_provider.identity_provider.provider_name]
  allowed_oauth_flows           = ["code"]
  allowed_oauth_scopes          = ["email", "openid", "profile"]
}
