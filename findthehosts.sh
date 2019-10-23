export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
export EC2KEYNAME=`terraform output --json | jq -r '.ec2_key_name.value'`
export JUMPHOSTIP=`terraform output --json | jq -r '.jumphost_ip.value[0]'`
echo connect at https://$BIGIPHOST0:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo ssh -i $EC2KEYNAME ubuntu@$JUMPHOSTIP