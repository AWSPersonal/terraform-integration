output "domain_url"{
    value = join(".com",[split(".com",aws_api_gateway_deployment.Deploy_API.invoke_url)[0]])
}