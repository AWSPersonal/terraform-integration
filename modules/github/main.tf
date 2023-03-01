resource "null_resource" "clone_repo" {
  triggers = {
    "always_run" = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "git clone -b ${var.git_branch} ${var.git_clone_url} ${var.git_destination}-repo"
  }
}