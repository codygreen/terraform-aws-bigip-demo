# Demo deployment of a BIG-IP and NGINX webapp using Terraform
Demo deployment of F5 BIG-IP in AWS using Terraform

an authentication token must be generated and recorded as documented below in order to access the modules required by this demo
https://www.terraform.io/docs/commands/cli-config.html

You can choose to run this from your workstation or a container. Follow the instructions below as appropriate;

# Using your workstation
- install Terraform https://learn.hashicorp.com/terraform/getting-started/install.html
- install inpsec https://www.inspec.io/downloads/
- install locust https://docs.locust.io/en/stable/installation.html
- install jq https://stedolan.github.io/jq/download/

# Using a Docker container
The 8089 port is opened in order to use the gui of the load generating tool
- install Docker Desktop (https://www.docker.com/products/docker-desktop)
- `docker run -it -v $(pwd):/workspace -p 8089:8089 mmenger/tfdemoenv:1.6.1 /bin/bash`

# Required Resource
This example creates the following resource inside of AWS.  Please ensure your IAM user or IAM Role has privileges to create these objects.

**Note:** This example requires 4 Elastic IPs, please ensure your EIP limit on your account can accommodate this (information on ElasticIP limits can be found at https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html#limits_ec2)
 - AWS VPC
 - AWS Route Tables
 - AWS Nat Gateways
 - AWS Elastic IPs
 - AWS EC2 Instances
 - AWS Subnets
 - AWS Security Groups
 
 **Note:** In order to use this demo your AWS account must be subscribed to the F5 AMI and its associated terms and conditions. If your account is not subscribed, the first time ```terraform apply``` is run you will receive an error similar to the following:

```
 Error: Error launching source instance: OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please 
visit https://aws.amazon.com/marketplace/pp?sku=XXXXXXXXXXXXXXXXXXXXXXXX
```
The url embedded within the error message will load the appropriate location in order to subscribe the AWS account to the F5 AMI.

After subscribing, re-run the ```terraform apply``` and the error should not occur again.

# Access Credentials
```bash
#starting from the directory where you cloned this repository
cd terraform-aws-bigip-demo
vi secrets.auto.tfvars
```
enter the following in the *secrets.auto.tfvars* file
```hcl
AccessKeyID         = "<AN ACCESS KEY FOR YOUR AWS ACCOUNT>" 
SecretAccessKey     = "<THE SECRET KEY ASSOCIATED WITH THE AWS ACCESS KEY>" 
ec2_key_name        = "<THE NAME OF AN AWS KEY PAIR WHICH IS ASSOCIATE WITH THE AWS ACOUNT>"
ec2_key_file        = "<THE PATH TO AN SSH KEY FILE USED TO CONNECT TO THE UBUNTU SERVER ONCE IT IS CREATED. NOTE: THIS PATH SHOULD BE RELATIVE TO THE CONTAINER ROOT>"
```
save the file and quit vi

# Setup 
```hcl
# initialize Terraform
terraform init
# build the NGINX nodes, the BIG-IPS, and the underpinning infrastructure
terraform apply 
```
Before proceeding you will need to wait as the BIG-IPs complete configuration. Once you are able to log into the BIG-IPs using the generated password you can proceed to the next command. The following Inspec tests validate the connectivity of the BIG-IP and the availability of the management API end point.

```
# check the status of the BIG-IPs
terraform output --json > inspec/bigip-ready/files/terraform.json
inspec exec inspec/bigip-ready
```
once the tests all pass the BIG-IP is ready

If terraform returns an error, rerun ```terraform apply```.

# log into the BIG-IP
```
# find the connection info for the BIG-IP
export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
export JUMPHOSTIP=`terraform output --json | jq -r '.jumphost_ip.value[0]'`
echo connect at https://$BIGIPHOST0:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo ssh -i "tfdemo.pem" ubuntu@$JUMPHOSTIP
```
connect to the BIGIP at https://<bigip_mgmt_public_ips>:<bigip_mgmt_port>
login as user:admin and password: <bigip_password>

# Creating Load
```
# find the ip address of the created BIG-IP 
export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
# start the locust instance 
cd locust
locust --host=http://$BIGIPHOST0
```
Go to the url created by locust to use the load generation gui.
Press ctrl-C when you are done with the load generation.

# Teardown
When you are done using the demo environment you will need to decommission it
```hcl
terraform destroy
```

as a final step check that terraform doesn't think there's anything remaining
```hcl
terraform show
```
this should return a blank line

