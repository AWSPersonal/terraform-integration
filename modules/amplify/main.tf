resource "aws_amplify_app" "amplify" {
  name         = "${var.name}-amplify-${terraform.workspace}"
  repository   = var.repository
  access_token = var.access_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm install env-cmd
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
}

resource "aws_amplify_branch" "branch" {
  app_id      = aws_amplify_app.amplify.id
  branch_name = var.branch
  framework   = var.framework
  stage       = var.stage
}

resource "aws_amplify_backend_environment" "backend_environment" {
  app_id           = aws_amplify_app.amplify.id
  environment_name = var.environment_name
}