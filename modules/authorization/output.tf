output role_arn_lambda{
  value = aws_iam_role.iam_for_lambda.arn
}

output role_arn_apig{
  value = aws_iam_role.iam_for_apig.arn
}

output policy_arn{
  value = aws_iam_policy.iam_policy_for_lambda.arn
}