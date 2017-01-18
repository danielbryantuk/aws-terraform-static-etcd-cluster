variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "current_location_cidr" {}

variable "instance_ssh_username" {}

variable "instance_private_key_file" {}

variable "instance_public_key_contents" {}

variable "owner" {
  default = "daniel"
}

variable "env" {
  default = "etcd"
}

variable "region" {
  default = "eu-west-1"
}

variable "vpc_cidr" {
  default = "10.42.0.0/16"
}

variable "availability_zones" {
  default = {
    zone0 = "eu-west-1a"
    zone1 = "eu-west-1b"
    zone2 = "eu-west-1c"
  }
}

variable "public_subnet_cidrs" {
  default = {
    zone0 = "10.42.100.0/24"
    zone1 = "10.42.101.0/24"
    zone2 = "10.42.102.0/24"
  }
}

variable "private_subnet_cidrs" {
  default = {
    zone0 = "10.42.0.0/24"
    zone1 = "10.42.1.0/24"
    zone2 = "10.42.2.0/24"
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
