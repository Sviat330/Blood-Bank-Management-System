resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env_code}-${var.ecs_family}"
  container_definitions    = <<DEFINITION
[
  {

    "name" : "${var.app_name[0]}",
    "image" : "${var.ecr_repo[0]}:latest",

    "essential" : true,

    "portMappings": [{
      "containerPort" : ${var.container_ports[0]},
      "hostPort"      : 0
    }],
    "environmentFiles": [
                {
                    "value": "${var.s3_arn}/${var.s3_key}",
                    "type": "s3"
                }
            ],
    "memory" : 150,
    "cpu"    : 150
  },
  {
    "essential" : false,
    "name"  : "${var.app_name[1]}",
    "image" : "${var.ecr_repo[1]}:latest",
    "portMappings" : [{
      "containerPort" : ${var.container_ports[1]},
      "hostPort"      : 0
    }],
  "dependsOn": [
   {
       "containerName": "${var.app_name[0]}",
       "condition": "START"
   }
  ],
    "memory" : 150,
    "cpu"    : 150

  }
]
DEFINITION
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
