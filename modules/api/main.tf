# Create a single API Gateway (REST)
resource "aws_api_gateway_rest_api" "apiLambda" {
  name = "psiog-${terraform.workspace}-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_lambda_permission" "apigw_proxy" {
  for_each      = var.endpoints
  statement_id  = uuid()
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/${each.value.prefix_url}/*"
}

