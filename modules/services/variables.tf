variable "function_name" {
  description = "Name of the current function"
  type        = string
}

variable "lambda_role" {
  type        = string
  description = "Role for the current function"
}

variable "policy" {
  description = "Policy for the current function"
}

variable "service" {
  description = "Service group of the current function"
  type        = string
}

variable "memory" {
  description = "Memory for the current function"
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "Timeout (in seconds) for the current function"
  type        = number
  default     = 3
}

variable "layer_name" {
  description = "Layer for the current function"
  type        = string
}

variable "source_folder" {
  type = string
}

variable "region" {
  type = string
}

variable environment_conf{
  type = map(any)
}

variable "prefix" {
  type = string
}