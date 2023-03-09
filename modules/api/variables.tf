variable "endpoints" {
  description = "value"
  type        = map(any)
}

variable "endpoint_name" {
  type = string
}

variable "endpoint_type" {
  type = list(string)
}
