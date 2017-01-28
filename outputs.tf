output "etcd public ELB address" {
  value = "${aws_elb.etcd.dns_name}"
}

output "jump_box_ip_ssh" {
  value = "ssh -A ubuntu@${aws_instance.jump_box.public_ip}"
}
