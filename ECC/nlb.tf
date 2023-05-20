resource "aws_lb_listener" "nlb_listener_frontend" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

/*
enable_cross_zone_load_balancing  =  true | false 
cross-zone load balancing of the load balancer will be enabled. 

For network and gateway type load balancers, 
this feature is disabled by default (false). 

For application load balancer this feature is always enabled (true) and cannot be disabled. 
Defaults to false.

*/

# load_balancer_type = "application" | "network" | "gateway"

resource "aws_lb" "nlb" {
  name                             = "${local.prefix}-nlb-poc"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = tolist(module.vpc.public_subnets)
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "${local.prefix}-nlb-poc-ad"
  }
}

# Target as ALB

resource "aws_lb_target_group" "nlb_target_group" {
  name        = "target-group-nlb-poc-ad"
  port        = 80
  target_type = "alb"
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id

}

# According to documentation
/*

**target_id** : The ID of the target. 
This is the Instance ID for an instance, or the container ID for an ECS container. 
If the target type is ip, specify an IP address. 
If the target type is lambda, specify the arn of lambda. 
If the target type is alb, specify the arn of alb.

*/
resource "aws_lb_target_group_attachment" "nlb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.nlb_target_group.arn
  target_id        = aws_lb.alb.arn
  port             = 80
  depends_on       = [aws_lb.alb, aws_lb_target_group_attachment.alb_target_group_attachment ]
}
