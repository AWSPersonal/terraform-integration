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

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.endpoints[each.key].invoke_arn
}