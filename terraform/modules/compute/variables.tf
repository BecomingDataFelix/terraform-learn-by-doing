variable "project" { type = string }
variable "env" { type = string }
variable "region" { type = string }

variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

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
} # optional

variable "frontend_desired_capacity" {
  type    = number
  default = 2
}

variable "frontend_min_size" {
  type    = number
  default = 1
}

variable "frontend_max_size" {
  type    = number
  default = 4
}

variable "backend_desired_capacity" {
  type    = number
  default = 1
}

variable "backend_min_size" {
  type    = number
  default = 1
}

variable "backend_max_size" {
  type    = number
  default = 2
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
} # replace in prod

variable "tags" {
  type = map(string)
  default = {
    "CreatedBy" = "Terraform"
  }
  description = "A map of tags to add to all resources"
}
