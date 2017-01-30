data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.instance_image}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.instance_image_provider_id}"]
}

data "template_file" "etcd_user_data" {
  template = "${file("templates/etcd-user-data.sh.tpl")}"

  vars {
    ca_pem_contents       = "${tls_self_signed_cert.ca.cert_pem}"
    etcd_key_pem_contents = "${tls_private_key.etcd.private_key_pem}"
    etc_pem_contents      = "${tls_locally_signed_cert.etcd.cert_pem}"
    etcd_private_ips = "${join(",",values(var.etcd_private_ips))}"
  }
}

resource "aws_instance" "etcd" {
  count         = "${length(var.availability_zones)}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  subnet_id              = "${element(aws_subnet.private.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.etcd-instance.id}"]
  private_ip             = "${lookup(var.etcd_private_ips, "zone${count.index}")}"

  key_name = "${aws_key_pair.daniel.key_name}"

  user_data = "${data.template_file.etcd_user_data.rendered}"

  tags {
    Name  = "${var.env}-instance-etcd${count.index}"
    Owner = "${var.owner}"
  }
}

resource "aws_instance" "jump_box" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.public.0.id}"
  vpc_security_group_ids      = ["${aws_security_group.etcd-instance.id}", "${aws_security_group.jump_box.id}"]
  private_ip                  = "${var.jump_box_private_ip}"

  key_name = "${aws_key_pair.daniel.key_name}"

  tags {
    Name  = "${var.env}-jump-box"
    Owner = "${var.owner}"
  }
}
