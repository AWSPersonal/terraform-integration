resource "aws_cognito_user_pool_domain" "domain" {
  depends_on = [
    aws_cognito_user_pool.pool
  ]
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.pool.id
}
