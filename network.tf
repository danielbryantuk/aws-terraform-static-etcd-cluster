# --- VPC

resource "aws_vpc" "etcd" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name  = "${var.env}-vpc"
    Owner = "${var.owner}"
  }
}

resource "aws_internet_gateway" "etcd" {
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name  = "${var.env}-internet-gateway"
    Owner = "${var.owner}"
  }
}

# --- public subnets

resource "aws_subnet" "public" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.etcd.id}"

  cidr_block        = "${lookup(var.public_subnet_cidrs, "zone${count.index}")}"
  availability_zone = "${lookup(var.availability_zones, "zone${count.index}")}"

  tags {
    Name  = "${var.env}-${lookup(var.availability_zones, "zone${count.index}")}-public-subnet"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table" "public" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.etcd.id}"

  route {
    cidr_block = "${var.cidr_range_all}"
    gateway_id = "${aws_internet_gateway.etcd.id}"
  }

  tags {
    Name  = "${var.env}-${lookup(var.availability_zones, "zone${count.index}")}-public-subnet-route"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_eip" "public_nat" {
  count = "${length(var.availability_zones)}"
  vpc   = true
}

resource "aws_nat_gateway" "public" {
  depends_on    = ["aws_internet_gateway.etcd"]
  count = "${length(var.availability_zones)}"
  allocation_id = "${element(aws_eip.public_nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}

# --- private subnets

resource "aws_subnet" "private" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.etcd.id}"

  cidr_block        = "${lookup(var.private_subnet_cidrs, "zone${count.index}")}"
  availability_zone = "${lookup(var.availability_zones, "zone${count.index}")}"

  tags {
    Name  = "${var.env}-${lookup(var.availability_zones, "zone${count.index}")}-private-subnet"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table" "private" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.etcd.id}"

  route {
    cidr_block     = "${var.cidr_range_all}"
    nat_gateway_id = "${element(aws_nat_gateway.public.*.id, count.index)}"
  }

  tags {
    Name  = "${var.env}-${lookup(var.availability_zones, "zone${count.index}")}-private-subnet-route"
    Owner = "${var.owner}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
