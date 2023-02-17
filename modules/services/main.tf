resource "aws_iam_role" "iam_for_lambda" {
  name = var.role_name

  assume_role_policy = <<EOF
  {
    "Version":"2012-10-17",
    "Statement": [
      {
        "Action":"sts:AssumeRole",
        "Principal":{
          "Service":"lambda.amazonaws.com"
        },
        "Effect":"Allow",
        "Sid":""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

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
  filename      = "${path.cwd}/compressed/${var.service}.zip"
  function_name = "psiog-integration-lambda-${var.service}"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  handler       = "${var.service}.index.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  depends_on = [
    aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role,
    data.archive_file.zip_the_python_code
  ]
}