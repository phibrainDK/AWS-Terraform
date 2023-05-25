resource "aws_security_group" "alb_sg" {
  name_prefix = "${local.prefix}-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "VPC-Enable TCP port - HTTP ingress #instance"
  }
  /*
  TESTING
  */
  ingress {
    from_port   = 433
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "VPC-Enable TCP port - HTTPS ingress #instance"
  }
  egress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    description = "VPC-Enable all possible ports responses #instance"
  }
  depends_on = [module.vpc]
}



resource "aws_lb" "alb" {
  name               = "${local.prefix}-alb-poc"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = tolist(module.vpc.public_subnets)
  /*
    access_logs {
    bucket  = aws_s3_bucket.logs_alb_s3.bucket
    prefix  = "alb-logs"
    enabled = true
    }
  */
  tags = {
    Name = "${local.prefix}-alb-poc-ad"
  }
}

# load_balancing_algorithm_type: "round_robin" | "least_outstanding_requests"

/*
stickiness: 
The only current possible values are lb_cookie, app_cookie for ALBs
source_ip for NLBs
and source_ip_dest_ip, source_ip_dest_ip_proto for GWLBs

stickiness.type: "lb_cookie" | "app_cookie" || "source_ip" || "source_ip_dest_ip" | "source_ip_dest_ip_proto"

cookie_name (*): required for "app_cookie"

deregistration_delay: connection draining  default -> [0, 3600]
*/

resource "aws_lb_target_group" "alb_target_group" {
  name                          = "VPC-target-group-alb-poc-ad"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = module.vpc.vpc_id
  load_balancing_algorithm_type = "round_robin"
  # deregistration_delay          = local.cooldown
  # para cookie por session
  # stickiness {
  #   enabled         = true
  #   type            = "lb_cookie"
  #   cookie_duration = 86400
  #   cookie_name     = "AWSALBCOOKIEPOCAD"
  # }
  health_check {
    path     = "/"
    protocol = "HTTP"
    interval = 15
    timeout  = 5
    port     = 80
  }
}

# aws_lb_listener : "forward" | "redirect" | "fixed-response"

resource "aws_lb_listener" "alb_listener_frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  # certificate_arn   = aws_acm_certificate.acm_certification.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = aws_lb_listener.alb_listener_frontend.arn
#   certificate_arn = aws_acm_certificate.acm_certification.arn
#   depends_on = [  ]
# }

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.alb_listener_frontend.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }
}

resource "aws_lb_listener_rule" "alb_health_check" {
  listener_arn = aws_lb_listener.alb_listener_frontend.arn

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY POC SG"
      status_code  = "200"
    }
  }

  condition {
    query_string {
      key   = "health"
      value = "check"
    }

    query_string {
      key   = "docs"
      value = "data"
    }
  }
}
