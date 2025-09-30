terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "state-bucket" {
  bucket              = var.state_bucket_name
  region              = var.region
  object_lock_enabled = true

  tags = {
    Name      = var.state_bucket_name
    ManagedBy = "terraform"
  }
}


resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
