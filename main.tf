provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

# --- VPC

resource "aws_vpc" "etcd" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
      Name = "${var.env}-vpc"
      Owner = "${var.owner}"
    }
}

resource "aws_internet_gateway" "etcd" {
    vpc_id = "${aws_vpc.etcd.id}"

    tags {
      Name = "${var.env}-internet-gateway"
      Owner = "${var.owner}"
    }
}

# --- public subnets

resource "aws_subnet" "zone-a-public" { #TODO - turn this into a count (with map for values)
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.public_subnet_cidr_a}"
    availability_zone = "${var.availability_zone_a}"

    tags {
        Name = "${var.env}-${var.availability_zone_a}-public-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_subnet" "zone-b-public" {
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.public_subnet_cidr_b}"
    availability_zone = "${var.availability_zone_b}"

    tags {
        Name = "${var.env}-${var.availability_zone_b}-public-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_subnet" "zone-c-public" {
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.public_subnet_cidr_c}"
    availability_zone = "${var.availability_zone_b}"

    tags {
        Name = "${var.env}-${var.availability_zone_b}-public-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_route_table" "zone-a-public" {
	vpc_id = "${aws_vpc.etcd.id}"

	route { # TODO - should we add a 10.42.0.0/16 -> local route?
		cidr_block = "${var.cidr_range_all}"
		gateway_id = "${aws_internet_gateway.etcd.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_a}-public-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table" "zone-b-public" {
	vpc_id = "${aws_vpc.etcd.id}"

	route {
		cidr_block = "${var.cidr_range_all}"
		gateway_id = "${aws_internet_gateway.etcd.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_b}-public-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table" "zone-c-public" {
	vpc_id = "${aws_vpc.etcd.id}"

	route {
		cidr_block = "${var.cidr_range_all}"
		gateway_id = "${aws_internet_gateway.etcd.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_b}-public-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table_association" "zone-a-public" {
  subnet_id = "${aws_subnet.zone-a-public.id}"
  route_table_id = "${aws_route_table.zone-a-public.id}"
}

resource "aws_route_table_association" "zone-b-public" {
  subnet_id = "${aws_subnet.zone-b-public.id}"
  route_table_id = "${aws_route_table.zone-b-public.id}"
}

resource "aws_route_table_association" "zone-c-public" {
  subnet_id = "${aws_subnet.zone-c-public.id}"
  route_table_id = "${aws_route_table.zone-c-public.id}"
}

resource "aws_eip" "zone-a-nat" {
  vpc = true
}

resource "aws_nat_gateway" "zone-a-public" {
  depends_on = ["aws_internet_gateway.etcd"]
  allocation_id = "${aws_eip.zone-a-nat.id}"
  subnet_id = "${aws_subnet.zone-a-public.id}"
}

resource "aws_eip" "zone-b-nat" {
  vpc = true
}

resource "aws_nat_gateway" "zone-b-public" {
  depends_on = ["aws_internet_gateway.etcd"]
  allocation_id = "${aws_eip.zone-b-nat.id}"
  subnet_id = "${aws_subnet.zone-b-public.id}"
}

resource "aws_eip" "zone-c-nat" {
  vpc = true
}

resource "aws_nat_gateway" "zone-c-public" {
  depends_on = ["aws_internet_gateway.etcd"]
  allocation_id = "${aws_eip.zone-c-nat.id}"
  subnet_id = "${aws_subnet.zone-c-public.id}"
}


# --- private subnets

resource "aws_subnet" "zone-a-private" {
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.private_subnet_cidr_a}"
    availability_zone = "${var.availability_zone_a}"

    tags {
        Name = "${var.env}-${var.availability_zone_a}-private-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_subnet" "zone-b-private" {
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.private_subnet_cidr_a}"
    availability_zone = "${var.availability_zone_b}"

    tags {
        Name = "${var.env}-${var.availability_zone_b}-private-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_subnet" "zone-c-private" {
    vpc_id = "${aws_vpc.etcd.id}"

    cidr_block = "${var.private_subnet_cidr_a}"
    availability_zone = "${var.availability_zone_c}"

    tags {
        Name = "${var.env}-${var.availability_zone_b}-private-subnet"
        Owner = "${var.owner}"
    }
}

resource "aws_route_table" "zone-a-private" {
	vpc_id = "${aws_vpc.etcd.id}"

	route {
		cidr_block = "${var.cidr_range_all}"
		nat_gateway_id = "${aws_nat_gateway.zone-a-public.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_a}-private-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table" "zone-b-private" {
	vpc_id = "${aws_vpc.etcd.id}"

	route {
		cidr_block = "${var.cidr_range_all}"
		nat_gateway_id = "${aws_nat_gateway.zone-b-public.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_b}-private-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table" "zone-c-private" {
	vpc_id = "${aws_vpc.etcd.id}"

	route {
		cidr_block = "${var.cidr_range_all}"
		nat_gateway_id = "${aws_nat_gateway.zone-c-public.id}"
	}

	tags {
		Name = "${var.env}-${var.availability_zone_c}-private-subnet-route"
		Owner = "${var.owner}"
	}
}

resource "aws_route_table_association" "zone-a-private" {
  subnet_id = "${aws_subnet.zone-a-private.id}"
  route_table_id = "${aws_route_table.zone-a-private.id}"
}

resource "aws_route_table_association" "zone-b-private" {
  subnet_id = "${aws_subnet.zone-b-private.id}"
  route_table_id = "${aws_route_table.zone-b-private.id}"
}

resource "aws_route_table_association" "zone-c-private" {
  subnet_id = "${aws_subnet.zone-c-private.id}"
  route_table_id = "${aws_route_table.zone-c-private.id}"
}
