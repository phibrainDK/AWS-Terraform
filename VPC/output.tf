output "alb_dns" {
  value = aws_lb.alb.dns_name
}
output "vpc_endpoints_all" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value = [for k, v in module.vpc_endpoints.endpoints : {
    arn       = v.arn
    dns_entry = v.dns_entry
    name      = v.tags_all.Name
  }]
}



