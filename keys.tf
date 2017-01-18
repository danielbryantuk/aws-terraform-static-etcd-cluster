resource "aws_key_pair" "daniel" {
  key_name   = "daniel"
  public_key = "${var.instance_public_key_contents}"
}
