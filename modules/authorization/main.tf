resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.role_name_lambda}-for-${terraform.workspace}"

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

resource "aws_iam_role" "iam_for_apig" {
  name = "${var.role_name_apig}-for-${terraform.workspace}"

  assume_role_policy = <<EOF
  {
    "Version":"2012-10-17",
    "Statement": [
      {
        "Action":"sts:AssumeRole",
        "Principal":{
          "Service":"apigateway.amazonaws.com"
        },
        "Effect":"Allow",
        "Sid":""
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "${var.policy_name_lambda}-for-${terraform.workspace}"
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