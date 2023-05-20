output "aws_instance_ips" {
  value = [for instance in aws_instance.aws_ec2 : {
    id         = instance.id
    private_ip = instance.private_ip
    public_ip  = instance.public_ip
  }]
}

output "aws_efs_mount_targets" {
  value = [for efs_target in aws_efs_mount_target.mount_target : {
    id              = efs_target.id
    subnet_id       = efs_target.subnet_id
    security_groups = efs_target.security_groups
  }]
}

output "aws_nlb_dns" {
  value = aws_lb.nlb.dns_name
}

output "aws_alb_dns" {
  value = aws_lb.alb.dns_name
}

output "bucket_name" {
  value = aws_s3_bucket.logs_alb_s3.bucket
}