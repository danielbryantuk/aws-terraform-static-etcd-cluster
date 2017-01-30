# etcd-terraform-play
This is a simple demonstration of the code required to deploy a static multi-AZ
[CoreOS etcd](https://github.com/coreos/etcd) cluster within AWS EC2 using
[HashiCorp's Terraform](https://www.terraform.io/) programmable infrastructure tool.

The Terraform code creates multi-AZ public and private subnets containing:
* Public
  * Elastic Load Balancer, forwarding to the etcd instances in the private subnets
  * NAT instances, for egress Internet-bound traffic from the etcd instances
  * A jump_box, which allows you to login externally via ssh, and then 'jump' to
   the etcd instances in the private subnets
* Private
  * etcd instances with private IPs (specified in the ```variables.tf```)

## Get started

To get started simply create a ```terraform.tfvars``` file in ```terraform```
directory with your AWS account/IAM User details. Your IAM User must have
[permissions](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
for AWS Lambda and AWS API Gateway.

The contents should follow the template below (with you replacing the info
  between ```<< >>```):

```
aws_access_key = "<< your IAM user AWS access key >>"
aws_secret_key = "<< your IAM user AWS secret key >>"
region = "<< your chosen region >>"

instance_ssh_username = "ubuntu"
instance_public_key_contents = "<< your AWS instance public key>>"

current_location_cidr = "<< CIDR block of you current location e.g 23.43.12.01/32 >>"

```
Then simply apply the Terraform configuration (when running this in production
it is strongly recommended save a ['plan'](https://www.terraform.io/docs/commands/plan.html)
first, and then apply this)

```
$ terraform apply
```

## Outputs
After the apply succeeds you will be presented with three outputs: a ssh login
to the jump_box, and two etcd example curl commands that are pre-configured with
the ELB location
```
Example etcd curl get = curl -L --insecure https://etcd-public-elb-1312041860.eu-west-1.elb.amazonaws.com:2379/v2/keys/message
Example etcd curl set = curl -L --insecure -X PUT https://etcd-public-elb-1312041860.eu-west-1.elb.amazonaws.com:2379/v2/keys/message -d value="Hello2"
jump_box_ip_ssh = ssh -A ubuntu@34.249.23.183
```

## Tidy up when finished!
When you are finished, don't forget to shut your infrastructure down:

```
$ terraform destroy -force
```

## Disclaimer
Please note: I'm not responsible for any costs incurred within your AWS account :-)
