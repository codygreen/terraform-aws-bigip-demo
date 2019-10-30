export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPHOST1=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[1]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
export EC2KEYNAME=`terraform output --json | jq -r '.ec2_key_name.value'`
export JUMPHOSTIP0=`terraform output --json | jq -r '.jumphost_ip.value[0]'`
export JUMPHOSTIP1=`terraform output --json | jq -r '.jumphost_ip.value[1]'`
echo connect at https://$BIGIPHOST0:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo scp -i $EC2KEYNAME.pem $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP0:~/$EC2KEYNAME.pem
echo ssh -i $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP0
echo
echo connect at https://$BIGIPHOST1:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo scp -i $EC2KEYNAME.pem $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP1:~/$EC2KEYNAME.pem
echo ssh -i $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP1