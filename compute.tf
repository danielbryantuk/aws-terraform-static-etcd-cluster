data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["${var.instance_image}"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["${var.instance_image_provider_id}"]
}


resource "aws_instance" "etcd0" { # TODO should be count
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  subnet_id = "${aws_subnet.zone-a-private.id}"
  vpc_security_group_ids = ["${aws_security_group.etcd-instance.id}"]

  tags {
    Name = "${var.env}-instance-0-etcd"
    Owner = "${var.owner}"
  }
}

resource "aws_instance" "etcd1" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  subnet_id = "${aws_subnet.zone-b-private.id}"
  vpc_security_group_ids = ["${aws_security_group.etcd-instance.id}"]

  tags {
    Name = "${var.env}-instance-1-etcd"
    Owner = "${var.owner}"
  }
}

resource "aws_instance" "etcd2" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  subnet_id = "${aws_subnet.zone-c-private.id}"
  vpc_security_group_ids = ["${aws_security_group.etcd-instance.id}"]

  tags {
    Name = "${var.env}-instance-2-etcd"
    Owner = "${var.owner}"
  }
}

# ------ ELB SG -------

resource "aws_security_group" "public-facing-elb" { #TODO hyphens
  name = "public_facing_elb"
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name = "${var.env}-public-facing-elb"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "allow_external_etcd_ingress" {
    type = "ingress"
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    cidr_blocks = ["${var.cidr_range_all}"]

    security_group_id = "${aws_security_group.public-facing-elb.id}"
}

resource "aws_security_group_rule" "allow_private_etcd_egress" { #TODO - double check this is required?
    type = "egress"
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.etcd-instance.id}"

    security_group_id = "${aws_security_group.public-facing-elb.id}"
}

# ------ ELB SG -------

resource "aws_security_group" "etcd-instance" {
  name = "etcd_instance"
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name = "${var.env}-etcd-instance"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "allow_external_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.current_location_cidr}"]

    security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_internal_etc_traffic" {
    type = "ingress"
    from_port = 2379
    to_port = 2380
    protocol = "tcp"
    self = true

    security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_elb_etc_ingress" {
    type = "ingress"
    from_port = 2379
    to_port = 2379
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.public-facing-elb.id}"

    security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_all_egress" { #TODO - is this too permissive?
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.cidr_range_all}"]

    security_group_id = "${aws_security_group.etcd-instance.id}"
}
