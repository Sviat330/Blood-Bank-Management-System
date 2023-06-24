
#Role and policies for lambda to allow required actions
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_policy" "lambda_basic" {
  name   = var.basic_lambda_policy_name
  policy = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : "logs:CreateLogGroup",
      "Resource" : ["arn:aws:logs:${data.aws_region.current.name}:${local.account_id}:*"]
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : [
        "${aws_iam_role.lambda_role.arn}"
      ]
    }
  ]
}
POLICY
}
locals {

  lambda_policies = [
    "${aws_iam_policy.lambda_basic.arn}",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "lambda_attach_policies" {
  count      = length(local.lambda_policies)
  role       = aws_iam_role.lambda_role.name
  policy_arn = local.lambda_policies[count.index]

}


#------------------------------------------------

#Role and policies for ec2 to allow required actions
resource "aws_iam_role" "ec2_role" {
  name = var.ec2_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
variable "ec2_policies" {
  type = list(any)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}


resource "aws_iam_role_policy_attachment" "ec2_attach_policies" {
  count      = length(var.ec2_policies)
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ec2_policies[count.index]

}



#------------------------------------------------------------


# Resource policy to allow eventbridge trigger lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}


#Instance profile for ec2 that is created by lambda

resource "aws_iam_instance_profile" "this" {
  name = "${var.env_code}-instance-profile-for-lambda"
  role = aws_iam_role.ec2_role.name
}
