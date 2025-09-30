variable "region" {
  default = "eu-west-1"
}

variable "project" {
  default = "example-webapp"
}

variable "env" {
  default = "dev"
}

# toggles
variable "enable_nat_gateway" {
  default = false # save cost in dev
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.1.101.0/24", "10.1.102.0/24"]
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
