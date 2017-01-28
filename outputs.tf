output "Example etcd curl get" {
  value = "curl -L --insecure https://${aws_elb.etcd.dns_name}:2379/v2/keys/message"
}

output "Example etcd curl set" {
  value = "curl -L --insecure -X PUT https://${aws_elb.etcd.dns_name}:2379/v2/keys/message -d value=\"Hello2\""
}

output "jump_box_ip_ssh" {
  value = "ssh -A ubuntu@${aws_instance.jump_box.public_ip}"
}
