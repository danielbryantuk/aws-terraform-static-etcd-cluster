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

  key_name = "${aws_key_pair.daniel.key_name}"

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

  key_name = "${aws_key_pair.daniel.key_name}"

  tags {
    Name = "${var.env}-instance-2-etcd"
    Owner = "${var.owner}"
  }
}

resource "aws_instance" "jump_box" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  associate_public_ip_address = true
  subnet_id = "${aws_subnet.zone-a-public.id}"
  vpc_security_group_ids = ["${aws_security_group.etcd-instance.id}"]

  key_name = "${aws_key_pair.daniel.key_name}"

  tags {
    Name = "${var.env}-jump-box"
    Owner = "${var.owner}"
  }
}
