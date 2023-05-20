/*
predefined_metric_type - (Required) Describes a scaling metric for a predictive scaling policy. 
Valid values are 
predefined_metric_type = "ASGAverageCPUUtilization" | "ASGAverageNetworkIn" |  "ASGAverageNetworkOut" | "ALBRequestCountPerTarget"
*/

resource "aws_autoscaling_policy" "dynamic_avgcpu_scaling_policy" {
  name                   = "${local.prefix}-dynamic-average_cpu_sp"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
      # resource_label         = "DynamicScalingPolicy-POC"
    }
    target_value = 10.0
  }
}

resource "aws_autoscaling_policy" "dynamic_requests_target_scaling_policy" {
  name                   = "${local.prefix}-dynamic-requests-target-sp"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.alb.arn_suffix}/${aws_lb_target_group.lb_target_group.arn_suffix}"
    }
    # target value should be number of requests
    target_value = 5
  }
}



resource "aws_autoscaling_policy" "predictive_customized_policy" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "${local.prefix}-customized-predictive-scaling-policy"
  policy_type            = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 10
      customized_load_metric_specification {
        metric_data_queries {
          id         = "load_sum"
          expression = "SUM(SEARCH('{AWS/EC2,AutoScalingGroupName} MetricName=\"CPUUtilization\" ${local.prefix}-metrics-logs-poc-ad', 'Sum', 3600))"
        }
      }
      customized_scaling_metric_specification {
        metric_data_queries {
          id = "scaling"
          metric_stat {
            metric {
              metric_name = "CPUUtilization"
              namespace   = "AWS/EC2"
              dimensions {
                name  = "AutoScalingGroupName"
                value = "${local.prefix}-metrics-logs-poc-ad"
              }
            }
            stat = "Average"
          }
        }
      }
      customized_capacity_metric_specification {
        metric_data_queries {
          id          = "capacity_sum"
          expression  = "SUM(SEARCH('{AWS/AutoScaling,AutoScalingGroupName} MetricName=\"GroupInServiceIntances\" ${local.prefix}-metrics-logs-poc-ad', 'Average', 300))"
          return_data = false
        }
        metric_data_queries {
          id          = "load_sum"
          expression  = "SUM(SEARCH('{AWS/EC2,AutoScalingGroupName} MetricName=\"CPUUtilization\" ${local.prefix}-metrics-logs-poc-ad', 'Sum', 300))"
          return_data = false
        }
        metric_data_queries {
          id         = "weighted_average"
          expression = "load_sum / capacity_sum"
        }
      }
    }
  }
}

resource "aws_autoscaling_schedule" "scheduled_actions" {
  scheduled_action_name  = "${local.prefix}-schedule-action-poc"
  min_size               = 1
  max_size               = 20
  desired_capacity       = 5
  start_time             = "2023-05-20T13:00:00Z"
  end_time               = "2023-05-20T14:00:00Z"
  time_zone              = "Etc/GMT-5"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


resource "aws_security_group" "security_group" {
  # count       = 4
  vpc_id      = module.vpc.vpc_id
  name_prefix = "ASG-poc-sg"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    description = "ASG - SSH log into linux #instance"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    description = "ASG - Port enable for redirect from Load Balancer"
  }
  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = aws_lb.alb.security_groups
    description     = "ASG - Access from Load Balancer"
  }
  egress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    description = "ASG - Enable all possible ports responses #instance"
  }
  depends_on = [module.vpc]
}

resource "aws_launch_template" "launch_template" {
  name = "${local.prefix}-launch-template-poc-ad"
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  image_id      = "ami-0c94855ba95c71c99"
  instance_type = "t3.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    subnet_id                   = module.vpc.public_subnets[0]
    security_groups             = [aws_security_group.security_group.id]
    associate_public_ip_address = true
  }
  user_data = base64encode(file("./mount_script.sh"))
  block_device_mappings {
    device_name = local.ebs_device_name1
    ebs {
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = 8
    }
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.lb_target_group.arn
}

resource "aws_autoscaling_group" "asg" {
  #   availability_zones = tolist(module.vpc.azs)
  name             = "${local.prefix}-asg-poc-ad"
  min_size         = 1
  max_size         = 20
  desired_capacity = 5
  default_cooldown = local.cooldown

  # vpc_zone_identifier  = tolist(module.vpc.private_subnets)
  # target_group_arns    = [aws_lb_target_group.lb_target_group.arn]
  termination_policies = ["OldestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour", "NewestInstance", "Default"]
  force_delete         = true
  tag {
    key                 = "${local.prefix}-poc"
    value               = "asg-ad"
    propagate_at_launch = true
  }
  /*
  TODO: update lifecycle hooks
  initial_lifecycle_hook {
    name                 = "${local.prefix}-lifecycle-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = jsonencode({
      status_code = 200,
      data        = "Mira las metricas"
    })
  }
  */
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      checkpoint_delay       = 300
    }
    triggers = ["tag"]
  }
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
      }
      override {
        instance_type     = "m5.large"
        weighted_capacity = "3"
        launch_template_specification {
          launch_template_id = aws_launch_template.launch_template.id
        }
      }
      override {
        instance_type     = "c5.xlarge"
        weighted_capacity = "2"
        launch_template_specification {
          launch_template_id = aws_launch_template.launch_template.id
        }
      }
    }
  }
  depends_on = [module.vpc, aws_launch_template.launch_template, aws_lb_target_group.lb_target_group]
}
