variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "owner" {
  default = "daniel"
}

variable "env" {
  default = "etcd"
}

variable "region" {
  default = "eu-west-1"
}

variable "availability_zone_a" {
  default = "eu-west-1a"
}

variable "availability_zone_b" {
  default = "eu-west-1b"
}

variable "availability_zone_c" {
  default = "eu-west-1c"
}

variable "vpc_cidr" {
  default = "10.42.0.0/16"
}

variable "public_subnet_cidr_a" {
  default = "10.42.100.0/24"
}

variable "public_subnet_cidr_b" {
  default = "10.42.101.0/24"
}

variable "public_subnet_cidr_c" {
  default = "10.42.102.0/24"
}

variable "private_subnet_cidr_a" {
  default = "10.42.0.0/24"
}

variable "private_subnet_cidr_b" {
  default = "10.42.1.0/24"
}

variable "private_subnet_cidr_c" {
  default = "10.42.2.0/24"
}

variable "private_subnet_cidrs" {
  default = {
    "0" = "10.42.0.0/24"
    "1" = "10.42.1.0/24"
    "2" = "10.42.2.0/24"
  }
}

variable "cidr_range_all" {
  default = "0.0.0.0/0"
}




variable "instance_image" {
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

variable "instance_image_provider_id" {
  default = "099720109477" #Canonical
}

variable "instance_type" {
  default = "t2.micro"
}


variable "current_location_cidr" {
  default = "217.138.34.2/32"
}

variable "instance_public_key_contents" {
}