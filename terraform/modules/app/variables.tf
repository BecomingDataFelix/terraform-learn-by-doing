variable "project" {
   type = string 
   default = "project-name-infrastructure"
   }
variable "env" {
   type    = string
   default = "dev"
}

variable "region" {
   type = string 
   default = "us-west-1"
  }

# network inputs
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

# compute inputs
variable "frontend_instance_type" {
  type    = string
  default = "t3.small"
}
variable "backend_instance_type" {
  type    = string
  default = "t3.small"
}
variable "key_name" {
  type    = string
  default = ""
}

# db inputs
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_security_group_ids" {
  type    = list(string)
  default = []
}
variable "db_engine" {
  type    = string
  default = "postgres"
}
variable "db_engine_version" {
  type    = string
  default = "15"
}

variable "secret_arn" {
  type    = string
  default = ""
}
variable "tags" {
  type = map(string)
  default = {
    CreatedBy = "Terraform"
  }
}
