resource "aws_api_gateway_resource" "api" {
  depends_on = [
    aws_api_gateway_rest_api.apiLambda
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "version" {
  depends_on = [
    aws_api_gateway_resource.api
  ]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "v1"
}

# Create a parent resource for each of the lambda functions
resource "aws_api_gateway_resource" "endpoints" {
  depends_on = [
    aws_api_gateway_resource.version
  ]
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