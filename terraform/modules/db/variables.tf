variable "project" { type = string }
variable "env" { type = string }

variable "private_subnet_ids" { type = list(string) }

variable "db_security_group_ids" { type = list(string) }

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "appdb"
}

# optional: existing secret (ARN). If provided, module reads username/password from it
variable "secret_arn" {
  type    = string
  default = ""
}

# whether to store the db endpoint to SSM
variable "save_endpoint_to_ssm" {
  type    = bool
  default = true
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    CreatedBy = "Terraform"
  }
}
