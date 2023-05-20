resource "aws_iam_role" "ec2_role" {
  count = local.n_instance
  name  = "${local.prefix}-ec2-role-poc-ad-${count.index}"
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

resource "aws_iam_policy" "ec2_policy" {
  count = local.n_instance
  name  = "${local.prefix}-ec2-policy-poc-ad-${count.index}"
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
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attachment" {
  count      = local.n_instance
  policy_arn = aws_iam_policy.ec2_policy[count.index].arn
  role       = aws_iam_role.ec2_role[count.index].name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = local.n_instance
  name  = "${local.prefix}-poc-ad-instance-profile-${count.index}"
  role  = aws_iam_role.ec2_role[count.index].name
}
