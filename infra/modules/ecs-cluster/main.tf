resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env_code}-${var.ecs_family}"
  container_definitions    = local.container_definition_with_env
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  network_mode             = "bridge"

}


resource "aws_ecs_cluster" "this" {
  name = "${var.env_code}-${var.ecs_family}-cluster"
}

resource "aws_ecs_service" "this" {
  name            = "${var.env_code}-${var.ecs_family}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.conts_desired_count

  load_balancer {

    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_name[1]
    container_port   = var.container_ports[1]
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 35

  depends_on = [aws_autoscaling_group.this]
}



resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.ecs_max_size
  min_capacity       = var.ecs_min_size
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.ecs_autoscale_role.arn


}

resource "aws_appautoscaling_policy" "ecs_cpu_memory" {
  name               = "${var.env_code}-${var.ecs_name}-cpu-scale"
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

  }
  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "${var.env_code}-${var.ecs_name}-memory-scale"
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

  }
  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_appautoscaling_policy" "ecs_target_requests" {
  name               = "${var.env_code}-${var.ecs_name}-request-scale"
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  target_tracking_scaling_policy_configuration {
    target_value       = 500
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    customized_metric_specification {
      metrics {
        label = "Get the sum of the request that made by alb"
        id    = "m1"
        metric_stat {
          metric {
            metric_name = "HTTP_Redirect_Count"
            namespace   = "AWS/ApplicationELB"

            dimensions {
              name  = "ALB-id"
              value = aws_lb.this.id
            }

          }
          stat = "Sum"
        }
        return_data = false
      }

      metrics {
        label = "Get the count of the inservice instances"
        id    = "m2"
        metric_stat {
          metric {
            metric_name = "GroupInServiceInstances"
            namespace   = "AWS/AutoScaling"
            dimensions {
              name  = "ASG-id"
              value = aws_autoscaling_group.this.id
            }
          }
          stat = "Sum"
        }
        return_data = false
      }
      metrics {
        label       = "Calculate the count of request that are made to one ec2"
        id          = "e1"
        expression  = "m1/m2"
        return_data = true
      }
    }

  }
}


