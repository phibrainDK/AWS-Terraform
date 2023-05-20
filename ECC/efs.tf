/*

performance_mode = generalPurpose | maxIO

*/
resource "aws_efs_file_system" "efs_file_system" {
  creation_token   = "${local.prefix}-efs-poc-ad"
  performance_mode = "generalPurpose"

  lifecycle {
    ignore_changes = [
      encrypted,
      performance_mode,
      throughput_mode,
      tags
    ]
  }
}


resource "aws_efs_mount_target" "mount_target" {
  count           = 4
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = module.vpc.public_subnets[count.index]
  security_groups = [aws_security_group.security_group.id]
  depends_on      = [module.vpc, aws_security_group.security_group, aws_efs_file_system.efs_file_system, aws_instance.aws_ec2]
}


