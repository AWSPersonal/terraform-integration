variable "git_clone_url" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "git_destination" {
  type        = string
  description = "This is the destination where the repository will be cloned"
}
