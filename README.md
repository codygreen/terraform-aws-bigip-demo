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
- docker run -it -p 8089:8089 -v $(pwd):/workspace mmenger/tfdemoenv:1.5.5 /bin/bash

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
Before starting create the user credentials and key pair you'll use to execute this demo

- [Create an IAM account in AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
- [How to Create an AWS Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

Securely store the .pem file for later use. You will not need it explicitly for this demo. You will need the Access Key, Secret Key, and Key Pair name for the following steps. 

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
```
save the file and quit vi

[Create an IAM account in AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

[How to Create an AWS Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

# Setup
You will need to build the demo out in stages. 
```hcl
# initialize Terraform
terraform init
# build the NGINX nodes, the BIG-IPS, and the underpinning infrastructure
terraform apply -target module.vpc -target module.nginx-demo-app -target module.bigip -target module.bigip_sg -target module.bigip_mgmt_sg -target module.demo_app_sg -target aws_secretsmanager_secret_version.bigip-pwd
```
In between the intial commands and the final command,  you will need to wait as the BIG-IPs complete configuration. Once you are able to log into the BIG-IPs using the generated password you can proceed to the next command.

```
# found in ./runtests.sh
# check the status of the BIG-IPs
terraform output --json > inspec/bigip-ready/files/terraform.json
inspec exec inspec/bigip-ready
```

```hcl
terraform apply
```
If terraform returns an error, rerun ```terraform apply```.

# log into the BIG-IP
```
# found in ./findthehosts.sh
# find the connection info for the BIG-IP
export BIGIPHOST0=`terraform output --json | jq n-r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
echo connect at https://$BIGIPHOST0:$BIGIPMGMTPORT
```
connect to the BIGIP at https://<bigip_mgmt_public_ips>:<bigip_mgmt_port>
login as user:admin and password: <bigip_password>

# view the NGINX web application
connect to the web application at http://<bigip_mgmt_public_ips>

# Creating Load
```
# found in ./runlocust.sh
# find the ip address of the created BIG-IP 
export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
# start the locust instance 
cd locust
locust --host=http://$BIGIPHOST0
```
Go to the url created by locust to use the load generation gui.
Press ctrl-C when you are done with the load generation.


# Teardown
=======
When you are done using the demo environment you will need to decommission in stages
```hcl
# remove the as3 configured partition
terraform destroy -target bigip_as3.as3-demo1 -target bigip_as3.as3-demo2
# remove the nginx demo application nodes
terraform destroy -target module.nginx-demo-app
# remove the BIG-IP and the underpinning infrastructure
terraform destroy -target module.vpc -target module.bigip -target module.bigip_sg -target module.bigip_mgmt_sg -target module.demo_app_sg -target aws_secretsmanager_secret_version.bigip-pwd -target random_password.password -target random_id.id -target aws_secretsmanager_secret.bigip
```

