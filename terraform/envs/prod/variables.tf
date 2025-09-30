variable "region" {
  default = "eu-west-1"
}

variable "project" {
  type  = string
  description = "Project name -- using default specified in app module"
}

variable "env" {
  default = "production"
}

# toggles
variable "enable_nat_gateway" {
  default = true 
}

variable "vpc_cidr" {
  default = "10.5.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.5.1.0/24", "10.5.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.5.101.0/24", "10.5.102.0/24"]
}

variable "frontend_instance_type" {
  default = "t3.micro"
}

variable "backend_instance_type" {
  default = "t3.micro"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_engine" {
  default = "postgres"
}

variable "db_engine_version" {
  default = "15"
} 

