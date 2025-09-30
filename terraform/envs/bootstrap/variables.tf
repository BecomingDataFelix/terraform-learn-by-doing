variable "region" {
  default = "eu-west-1"
}

variable "state_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Terraform state."
  default = "${var.project}-tfstate-${timestamp().date}"  # ensure globally unique name
}

