export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPHOST1=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[1]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
export EC2KEYNAME=`terraform output --json | jq -r '.ec2_key_name.value'`
export JUMPHOSTIP0=`terraform output --json | jq -r '.jumphost_ip.value[0]'`
export JUMPHOSTIP1=`terraform output --json | jq -r '.jumphost_ip.value[1]'`
export JUICESHOP0=`terraform output --json | jq -r '.juiceshop_ip.value[0]'`
export JUICESHOP1=`terraform output --json | jq -r '.juiceshop_ip.value[1]'`
export GRAFANA0=`terraform output --json | jq -r '.grafana_ip.value[0]'`
export GRAFANA1=`terraform output --json | jq -r '.grafana_ip.value[1]'`
echo '** AVAILABILITY ZONE 1 **'
echo connect to BIG-IP at https://$BIGIPHOST0:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo scp -i $EC2KEYNAME.pem $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP0:~/$EC2KEYNAME.pem
echo ssh -i $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP0
echo when the ansible run is complete Juiceshop and Grafana should be available at
echo Juice Shop http://$JUICESHOP0
echo Grafana http://$GRAFANA0
echo 
echo
echo '** AVAILABILITY ZONE 2 **'
echo connect to BIG-IP at https://$BIGIPHOST1:$BIGIPMGMTPORT with $BIGIPPASSWORD
echo connect to jumphost at with
echo scp -i $EC2KEYNAME.pem $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP1:~/$EC2KEYNAME.pem
echo ssh -i $EC2KEYNAME.pem ubuntu@$JUMPHOSTIP1
echo when the ansible run is complete Juiceshop and Grafana should be available at
echo Juice Shop http://$JUICESHOP1
echo Grafana http://$GRAFANA1
