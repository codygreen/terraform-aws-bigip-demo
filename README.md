# Demo deployment of a BIG-IP and NGINX webapp using Terraform
Demo deployment of F5 BIG-IP in AWS using Terraform

an authentication token must be generated and recorded as documented below in order to access the modules required by this demo
https://www.terraform.io/docs/commands/cli-config.html

# Setup
You will need to build the demo out in stages
```hcl
terraform init
terraform apply -target module.vpc -target module.nginx-demo-app -target module.bigip
teraform apply