variable "tf_logs_alb_bucket_name" {
  description = "The bucket name to store ALB logs"
  type        = string
  default     = "vpc-alb-logs-poc-ad"
}