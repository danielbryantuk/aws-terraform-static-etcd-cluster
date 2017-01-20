# ------ ELB SG -------

resource "aws_security_group" "public-facing-elb" {
  name   = "public_facing_elb"  #TODO hyphens
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name  = "${var.env}-public-facing-elb"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "allow_external_etcd_ingress" {
  type        = "ingress"
  from_port   = 2379
  to_port     = 2379
  protocol    = "tcp"
  cidr_blocks = ["${var.cidr_range_all}"]

  security_group_id = "${aws_security_group.public-facing-elb.id}"
}

resource "aws_security_group_rule" "allow_private_etcd_egress" {
  type                     = "egress"                                 #TODO - double check this is required?
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.etcd-instance.id}"

  security_group_id = "${aws_security_group.public-facing-elb.id}"
}

resource "aws_security_group_rule" "allow_external_elb_ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.current_location_cidr}"]

  security_group_id = "${aws_security_group.public-facing-elb.id}"
}

resource "aws_security_group_rule" "allow_private_elb_ssh_egress" {
  type                     = "egress"                                 #TODO - double check this is required?
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.etcd-instance.id}"

  security_group_id = "${aws_security_group.public-facing-elb.id}"
}

# ------ etcd SG -------

resource "aws_security_group" "etcd-instance" {
  name   = "etcd_instance"
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name  = "${var.env}-etcd-instance"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "allow_internal_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.public-facing-elb.id}"

  security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_jump_box_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jump_box.id}"

  security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_internal_etc_traffic" {
  type      = "ingress"
  from_port = 2379
  to_port   = 2380
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_elb_etc_ingress" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.public-facing-elb.id}"

  security_group_id = "${aws_security_group.etcd-instance.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type        = "egress"                  #TODO - is this too permissive?
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${var.cidr_range_all}"]

  security_group_id = "${aws_security_group.etcd-instance.id}"
}

# ------ jump box -------

resource "aws_security_group" "jump_box" {
  name   = "jump_box"
  vpc_id = "${aws_vpc.etcd.id}"

  tags {
    Name  = "${var.env}-jump-box"
    Owner = "${var.owner}"
  }
}

resource "aws_security_group_rule" "allow_external_jump_box_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks = ["${var.current_location_cidr}"]

  security_group_id = "${aws_security_group.jump_box.id}"
}

resource "aws_security_group_rule" "allow_jump_box_all_egress" {
  type        = "egress"                  #TODO - is this too permissive?
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${var.cidr_range_all}"]

  security_group_id = "${aws_security_group.jump_box.id}"
}
