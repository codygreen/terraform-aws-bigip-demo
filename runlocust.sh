# find the ip address of the created BIG-IP 
export BIGIPHOST0=`terraform output --json | jq '.bigip_mgmt_public_ips.value[0]' | sed 's/"//g'`
# start the locust instance 
cd locust
locust --host=http://$BIGIPHOST0
cd ..