resource "aws_elb" "etcd" {
  name = "${var.env}-public-elb"

  subnets = ["${aws_subnet.public.*.id}"]

  listener {
    instance_port     = 2379
    instance_protocol = "tcp"
    lb_port           = 2379
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3

    /*TODO change this*/
    /*target = "HTTP:2379/health"*/
    target = "TCP:22"

    interval = 30
  }

  instances                   = ["${aws_instance.etcd.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = ["${aws_security_group.public-facing-elb.id}"]

  tags {
    Name  = "${var.env}-public-elb"
    Owner = "${var.owner}"
  }
}
