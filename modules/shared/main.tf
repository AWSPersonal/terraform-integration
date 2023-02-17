resource "null_resource" "Install-Dependencies" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = join(" && ", [
      "mkdir -p build/${var.service}/python",
      "pip install -r requirements.txt -t build/${var.service}/python",
      "cp -r functions/shared_services build/${var.service}/python"
    ])
  }
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "build/${var.service}"
  output_path = "build/compressed/${var.service}.zip"
  depends_on = [
    null_resource.Install-Dependencies
  ]
}

resource "aws_lambda_layer_version" "shared_layer" {
  filename   = "build/compressed/${var.service}.zip"
  layer_name = "Shared-${terraform.workspace}-Layer"

  compatible_runtimes = ["python3.9"]
}
