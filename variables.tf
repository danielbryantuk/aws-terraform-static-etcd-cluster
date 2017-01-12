variable "owner" {
  value = "daniel"
}

variable "env" {
  value = "etcd-"
}

variable "vpc_cidr" {
  value = "10.42.0.0/16"
}

variable "region" {
  value = "eu-west-1"
}

variable "availability_zone_a" {
  value = "${var.region}a"
}

variable "availability_zone_b" {
  value = "${var.region}b"
}

variable "availability_zone_c" {
  value = "${var.region}c"
}

variable "vpc_cidr" {
  value = "10.42.0.0/16"
}

variable "public_subnet_cidr_a" {
  value = "10.42.100.0/24"
}

variable "public_subnet_cidr_b" {
  value = "10.42.101.0/24"
}

variable "public_subnet_cidr_c" {
  value = "10.42.102.0/24"
}

variable "private_subnet_cidr_a" {
  value = "10.42.0.0/24"
}

variable "private_subnet_cidr_b" {
  value = "10.42.1.0/24"
}

variable "private_subnet_cidr_c" {
  value = "10.42.2.0/24"
}

variable "cidr_range_all" {
  value = "0.0.0.0/0"
}
