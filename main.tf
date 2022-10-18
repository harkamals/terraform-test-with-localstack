resource "aws_s3_bucket" "test-bucket" {
  bucket = var.bucket_name
}

variable "bucket_name" {}

output "arn" {
  value = aws_s3_bucket.test-bucket.arn
}

output "name" {
  value = aws_s3_bucket.test-bucket.bucket
}

output "object_lock_enabled" {
  value = aws_s3_bucket.test-bucket.object_lock_enabled
}
