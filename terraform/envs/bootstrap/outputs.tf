output "state_s3_bucket_name" {
  value = aws_s3_bucket.state-bucket.bucket
}

output "state_s3_region" {
  value = aws_s3_bucket.state-bucket.region
}
