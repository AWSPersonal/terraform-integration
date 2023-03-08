output "function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "service_name" {
  value = var.service
}

output "environment_variables" {
  value = var.environment_conf
}

output "available_services" {
  value = {
    "${var.service}" = {
      function_name    = aws_lambda_function.lambda_function.function_name
      path             = var.service
      prefix_url       = "api/v1/${var.service}"
      invoke_arn       = aws_lambda_function.lambda_function.invoke_arn
      environment_conf = var.environment_conf
    }
  }
}
