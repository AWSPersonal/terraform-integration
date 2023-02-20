variable "role_name_lambda" {
  description = "Value of the name for the role assigned to lambda function"
  type        = string
  default     = "iam_role_lambda"
}

variable "role_name_apig" {
  description = "Value of the name for the role assigned to api gateway"
  type        = string
  default     = "iam_role_apig"
}

variable "policy_name_lambda" {
  description = "Value of the name for the role assigned to lambda function"
  type        = string
  default     = "iam_role"
}
