# Demo deployment of a BIG-IP and NGINX webapp using Terraform
Demo deployment of F5 BIG-IP in AWS using Terraform

an authentication token must be generated and recorded as documented below in order to access the modules required by this demo
https://www.terraform.io/docs/commands/cli-config.html

# Required Resource
This example creates the following resource inside of AWS.  Please ensure your IAM user or IAM Role has privileges to create these objects.

**Note:** This example requires 3 Elastic IPs, please ensure you EIP limit on your account can accommodate this (information on ElasticIP limits can be found at https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_ec2)
 - AWS VPC
 - AWS Route Tables
 - AWS Nat Gateways
 - AWS Elastic IPs
 - AWS EC2 Instances
 - AWS Subnets
 - AWS Security Groups

# Setup
You will need to build the demo out in stages
```hcl
terraform init
terraform apply -target module.vpc -target module.nginx-demo-app -target module.bigip -target module.bigip_sg -target module.bigip_mgmt_sg -target module.demo_app_sg
teraform apply
```