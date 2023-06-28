output "s3_arn_out" {
  value = aws_s3_bucket.this.arn
}
output "s3_name_out" {
  value = aws_s3_bucket.this.id
}
output "s3_key_out" {
  value = var.s3_key
}


