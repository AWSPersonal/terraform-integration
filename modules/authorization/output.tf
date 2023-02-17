output role_arn{
  value = aws_iam_role.iam_for_lambda.arn
}

output policy_arn{
  value = aws_iam_policy.iam_policy_for_lambda.arn
}