variable function_name{
  description = "Value of the name tag for the EC2 instance"
  type=string
  default="psiog-integration-lambda-dispatches"
}

variable role_name{
  description = "Value of the name for the role assigned to lambda function"
  type=string
  default="iam_for_lambda"
}

variable service{
  description = "Value of the name of the service"
  type=string
}