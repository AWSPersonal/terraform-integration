variable "table_name" {
  type        = string
  description = "Table name for dynamo db"
}

variable "billing_mode" {
  type = string
}

variable "read_capacity" {
  type = number
}

variable "write_capacity" {
  type = number
}

variable "hash_key" {
  type = string
}

variable "range_key" {
  type = string
}