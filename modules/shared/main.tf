resource "null_resource" "Install-Dependencies" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = join(" && ", [
      "mkdir -p build/${var.service}/python",
      "pip install -r ${var.source_folder}/requirements.txt -t build/${var.service}/python",
      "cp -r ${var.source_folder}/shared_services build/${var.service}/python"
    ])
  }
}

data "archive_file" "ZIP-Shared" {
  type        = "zip"
  source_dir  = "build/${var.service}"
  output_path = "build/compressed/${var.service}.zip"
  depends_on = [
    null_resource.Install-Dependencies
  ]
}

resource "aws_lambda_layer_version" "shared_layer" {
  filename   = "build/compressed/${var.service}.zip"
  layer_name = "Shared-${upper(terraform.workspace)}-Layer"
  depends_on = [
    data.archive_file.ZIP-Shared
  ]
  source_code_hash = data.archive_file.ZIP-Shared.output_base64sha256
  skip_destroy = true
  compatible_runtimes = ["python3.9"]
}
