output "function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "environment_variables" {
  value = var.environment_conf
}

output "available_services" {
  value = {
    "${var.prefix}" = {
      function_name    = aws_lambda_function.lambda_function.function_name
      path             = var.prefix
      prefix_url       = "api/v1/${var.prefix}"
      invoke_arn       = aws_lambda_function.lambda_function.invoke_arn
      environment_conf = var.environment_conf
    }
  }
}
