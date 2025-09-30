terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random" }
  }

  backend "s3" {
    bucket  = module.bootstrap.state_s3_bucket_name
    key     = "${var.env}/terraform.tfstate"
    region  = module.bootstrap.state_s3_region
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

