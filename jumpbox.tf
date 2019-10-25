

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


module "jumphost" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = format("%s-demo-jumphost-%s", var.prefix, random_id.id.hex)
  instance_count = 1

  ami                         = data.aws_ami.latest-ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t2.large"
  key_name                    = var.ec2_key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.bigip_mgmt_sg.this_security_group_id]
  subnet_ids                  = module.vpc.database_subnets

  # this box needs to know the ip address of the bigip and the juicebox host
  # it also needs to know the bigip username and password to use

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Application = var.prefix
  }
}

resource "null_resource" "transfer" {
  provisioner "file" {
    content     = templatefile(
      "${path.module}/hostvars_template.yml",
          {
            bigip_host_ip          = module.bigip.mgmt_public_ips[0] # the ip address that the bigip has on the management subnet
            bigip_host_dns         = module.bigip.mgmt_public_dns[0] # the DNS name of the bigip on the public subnet
            bigip_domain           = "${var.region}.compute.internal"
            bigip_username         = "admin"
            bigip_password         = random_password.password.result
            bigip_external_self_ip = data.aws_network_interface.bar[0].private_ip # the ip address that the bigip has on the public subnet
            bigip_internal_self_ip = module.bigip.mgmt_public_ips[0] # the ip address that the bigip has on the private subnet
            appserver_virtual_ip   = cidrhost(cidrsubnet(var.cidr,8,0),125)
            appserver_gateway_ip   = cidrhost(cidrsubnet(var.cidr,8,20),1)
            appserver_guest_ip     = cidrhost(cidrsubnet(var.cidr,8,20),10)
            appserver_host_ip      = module.jumphost.private_ip[0]   # the ip address that the jumphost has on the public subnet
          }
    )

    destination = "~/inventory.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ec2_key_file)
      host        = module.jumphost.public_ip[0]
    }  
  }
}