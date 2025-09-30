variable "project" {
  type        = string
  description = "The name of the project, used for tagging and naming resources"
}

variable "env" {
  type        = string
  description = "The environment (e.g. dev, staging, prod), used for tagging and naming resources"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy the resources"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

# lists of CIDRs per availability zone (must match AZ count)
variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "A list of CIDR blocks for the public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "A list of CIDR blocks for the private subnets"
}

variable "enable_nat_gateway" {
  type    = bool
  default = var.env == "dev" ? false : true
} # true for staging/prod

variable "tags" {
  type = map(string)
  default = {
    "CreatedBy" = "Terraform"
  }
  description = "A map of tags to add to all resources"
}
