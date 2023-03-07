resource "aws_cognito_identity_provider" "identity_provider" {
  depends_on = [
    aws_cognito_user_pool.pool
  ]
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
