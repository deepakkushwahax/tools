variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  default = "ap-south-1a"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ami_id" {
  default = "ami-021a584b49225376d" # Ubuntu 22.04 LTS for ap-south-1
}

variable "key_name" {
  description = "SonarKey"
  type        = string
}