variable "name" {
  type = string
}

variable "client_name" {
  type = string
}

variable "schema" {
  type = list(map(string))
}

variable "domain_name" {
  type = string
}
