data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.ecs_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.ecs_name}-iam-role"
    Environment = var.env_code
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}



resource "aws_iam_policy" "S3_get_env_object" {
  name        = "S3_get_env_object"
  description = "test - access to source and destination S3 bucket"
  path        = "/"
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" = "Allow"
        "Action" = [
          "s3:GetObject"
        ]
        "Resource" = [
          "${var.s3_arn}/${var.s3_key}"
        ]
      },
      {
        "Effect" = "Allow"
        "Action" = [
          "s3:GetBucketLocation"
        ]
        "Resource" = [
          "${var.s3_arn}"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  count      = length(["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role", aws_iam_policy.S3_get_env_object.arn])
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = element(["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role", aws_iam_policy.S3_get_env_object.arn], count.index)
}

