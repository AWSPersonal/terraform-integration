resource "null_resource" "do-build" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = join(" && ", [
      "mkdir -p build/${var.service}",
      "cp -R functions/${var.service} build/${var.service}/"
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

resource "aws_lambda_function" "dispatches_function" {
  filename         = "build/compressed/${var.service}.zip"
  function_name    = "psiog-${terraform.workspace}-lambda-${var.service}"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  handler          = "${var.service}.index.lambda_handler"
  role             = var.role
  runtime          = "python3.9"
  layers           = [var.layer_name]
  memory_size      = var.memory
  timeout          = var.timeout
  environment {
    variables = var.environment_conf
  }
  depends_on = [
    var.policy,
    data.archive_file.zip_the_python_code
  ]
}
