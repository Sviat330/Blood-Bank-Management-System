
#Archieve folder that contain
data "archive_file" "python_lambda_package" {
  count       = var.restore_db ? 1 : 0
  type        = "zip"
  output_path = "lambda_function.zip"
  source_file = "${path.module}/code/lambda_function.py"
}

#Lambda function that will create ec2 instance by trigger 
resource "aws_lambda_function" "this" {
  count            = var.restore_db ? 1 : 0
  function_name    = "${var.env_code}-lambda-for-restore-db"
  filename         = "lambda_function.zip"
  role             = aws_iam_role.lambda_role[0].arn
  source_code_hash = data.archive_file.python_lambda_package[0].output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  environment {
    variables = {
      SUBNET_ID       = "${var.public_subnet_ids[0]}",
      DB_USERNAME     = "${var.db_username}",
      DB_PORT         = var.db_port,
      DB_PASS         = var.pass,
      DB_NAME         = var.db_name,
      REGION          = data.aws_region.current.name,
      InstanceProfile = aws_iam_instance_profile.this[0].arn

    }
  }

}
