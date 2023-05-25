resource "aws_flow_log" "vpc_flowlogs" {
  iam_role_arn    = aws_iam_role.vpc_flowlogs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flowlogs_cloudwatch.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
  depends_on      = [aws_cloudwatch_log_group.vpc_flowlogs_cloudwatch, aws_iam_role.vpc_flowlogs_role]
}

resource "aws_cloudwatch_log_group" "vpc_flowlogs_cloudwatch" {
  name              = "${local.prefix}-cloudwatch-log-group"
  retention_in_days = 0
  lifecycle {
    prevent_destroy = false
  }
}