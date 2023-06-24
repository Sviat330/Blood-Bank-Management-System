



resource "aws_cloudwatch_event_target" "this" {

  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.this.id
  input_transformer {
    input_paths = {
      "DB_ID" : "$.detail.SourceIdentifier"
    }
    input_template = <<EOF
{
  "DB_ID": <DB_ID>
}
EOF
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name          = "${var.env_code}-creation-db-rule"
  description   = "Capture creation of rds db instance"
  event_pattern = <<PATTERN
  {
    "source" : ["aws.rds"],
    "detail-type" : ["RDS DB Instance Event"],
    "detail" : {
      "EventID" : ["RDS-EVENT-0005"]
    }
  }
PATTERN
}
