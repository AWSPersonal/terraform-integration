# Create a single API Gateway (REST)
resource "aws_api_gateway_rest_api" "apiLambda" {
  name = "psiog-${terraform.workspace}-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id      = aws_api_gateway_rest_api.apiLambda.id
  resource_id      = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "root_method_mock" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_method.root_method.resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "options_200" {
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
  depends_on = [
    aws_api_gateway_integration.root_method_mock
  ]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = "OPTIONS"
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "version" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "v1"
}

# Create a parent resource for each of the lambda functions
resource "aws_api_gateway_resource" "endpoints" {
  for_each    = var.endpoints
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_resource.version.id
  path_part   = each.value.path
}

# Create a child resource for each endpoint as Proxy
resource "aws_api_gateway_resource" "proxy" {
  for_each    = aws_api_gateway_resource.endpoints
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = each.value.id
  path_part   = "{proxy+}"
}

# Create the link between proxy resource and the lambda function
resource "aws_api_gateway_method" "proxy_method" {
  for_each      = aws_api_gateway_resource.proxy
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = each.value.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "proxy_response" {
  for_each    = aws_api_gateway_method.proxy_method
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "proxy_integration_response" {
  for_each    = aws_api_gateway_method_response.proxy_response
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = each.value.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration" "proxy_lambda" {
  for_each    = aws_api_gateway_method.proxy_method
  rest_api_id = each.value.rest_api_id
  resource_id = each.value.resource_id
  http_method = each.value.http_method

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.endpoints[each.key].invoke_arn
}

resource "aws_lambda_permission" "apigw_proxy" {
  for_each      = var.endpoints
  statement_id  = uuid()
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/${each.value.prefix_url}/*"
}

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

