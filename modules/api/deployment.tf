resource "aws_api_gateway_deployment" "Deploy_API" {
  depends_on = [
    aws_lambda_permission.apigw_proxy,
    aws_api_gateway_integration.proxy_lambda,
    aws_api_gateway_integration_response.proxy_integration_response,
    aws_api_gateway_integration_response.options_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = terraform.workspace
}