resource "null_resource" "do-build" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = join(" && ", [
      "mkdir -p build/${var.service}",
      "cp -R ${var.source_folder}/functions/${var.service} build/${var.service}/"
    ])
  }
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "build/${var.service}"
  output_path = "build/compressed/${var.service}.zip"
  depends_on = [
    null_resource.do-build
  ]
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "build/compressed/${var.service}.zip"
  function_name    = var.function_name
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  handler          = "${var.service}.main.handler"
  role             = var.lambda_role
  runtime          = "python3.9"
  layers           = [var.layer_name]
  memory_size      = var.memory
  timeout          = var.timeout
  depends_on = [
    data.archive_file.zip_the_python_code
  ]
}
