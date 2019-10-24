export BIGIPHOST0=`terraform output --json | jq -r '.bigip_mgmt_public_ips.value[0]'`
export BIGIPMGMTPORT=`terraform output --json | jq -r '.bigip_mgmt_port.value'`
export BIGIPPASSWORD=`terraform output --json | jq -r '.bigip_password.value'`
echo connect at https://$BIGIPHOST0:$BIGIPMGMTPORT with $BIGIPPASSWORD
