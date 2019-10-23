#
# Create the VPC 
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = format("%s-vpc-%s", var.prefix, random_id.id.hex)
  cidr                 = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs = var.azs

  public_subnets = [for num in range(length(var.azs)) :
      cidrsubnet(var.cidr, 8, num)
  ]
  
  # using the database subnet method since it allows a public route
  database_subnets = [
    for num in range(length(var.azs)) :
    cidrsubnet(var.cidr, 8, num + 10)
  ]
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  private_subnets = [
    for num in range(length(var.azs)) :
    cidrsubnet(var.cidr, 8, num + 20)
  ]

  enable_nat_gateway = true

  tags = {
    Name        = format("%s-vpc-%s", var.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = "dev"
  }
}


