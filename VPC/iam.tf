resource "aws_iam_role" "ec2_role" {
  name = "${local.prefix}-ec2-role-poc-ad"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role" "vpc_flowlogs_role" {
  name = "${local.prefix}-vpc-flowlogs-role-poc-ad"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_policy" "ec2_policy" {
  name = "${local.prefix}-ec2-policy-poc-ad"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:CreateMountTarget",
          "elasticfilesystem:DeleteMountTarget",
          "elasticfilesystem:DeleteFileSystem",
          "elasticfilesystem:DescribeFileSystems",
          "s3:PutObject",
          "s3:ListObjects",
          "s3:ListBuckets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "vpc_flowlogs_policy" {
  name = "${local.prefix}-vpc-flowlogs-policy-poc-ad"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeFlowLogs",
          "ec2:CreateFlowLogs"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_attachment" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "vpc_flowlogs_attachment" {
  policy_arn = aws_iam_policy.vpc_flowlogs_policy.arn
  role       = aws_iam_role.vpc_flowlogs_role.name
}



resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.prefix}-poc-ad-instance-profile"
  role = aws_iam_role.ec2_role.name
}
