# copyright: 2018, The Authors

title "Verify BIG-IP availability"


# load data from Terraform output
# created by terraform output --json > bigip/files/terraform.json
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

BIGIP_DNS  = params['bigip_mgmt_public_ips']['value']
BIGIP_PORT = params['bigip_mgmt_port']['value']

control "Connectivity" do
  impact 1.0
  title "BIGIP is reachable"

  BIGIP_DNS.each do |bigip_host|
    describe host(bigip_host, port: BIGIP_PORT, protocol: 'tcp') do
        it { should be_reachable }
    end
    # TODO: include testing of authentication against API
  end
end 



