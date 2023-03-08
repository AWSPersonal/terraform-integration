resource "aws_api_gateway_method" "root_method" {
  depends_on = [
    aws_api_gateway_rest_api.apiLambda
  ]
  rest_api_id      = aws_api_gateway_rest_api.apiLambda.id
  resource_id      = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "root_method_mock" {
  depends_on = [
    aws_api_gateway_method.root_method
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_method.root_method.resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "options_200" {
  depends_on = [
    aws_api_gateway_integration.root_method_mock
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  status_code = "200"
  response_models = {
    "application/json" : "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  depends_on = [
    aws_api_gateway_method_response.options_200
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = "OPTIONS"
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }
}