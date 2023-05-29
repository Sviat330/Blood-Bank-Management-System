


data "template_file" "test" {
  template = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.env_code}-${var.ecs_family}-cluster >> /etc/ecs/ecs.config
  EOF
}
resource "aws_launch_template" "this" {
  name = "${var.env_code}-lt"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }
  image_id               = var.instance_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2agent_sg.id]
  key_name               = data.aws_key_pair.example.key_name
  user_data              = base64encode(data.template_file.test.rendered)
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.env_code}-${var.ecs_family}-cluster"
  min_size            = var.ec2_min_size
  max_size            = var.ec2_max_size
  desired_capacity    = var.ec2_des_cap
  vpc_zone_identifier = var.public_subnets_id
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  tag {
    key                 = "ecs_cluster"
    value               = "${var.env_code}-${var.ecs_family}-cluster"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = "test"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn
  }

}
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }

}

