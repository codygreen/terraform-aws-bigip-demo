# copyright: 2018, The Authors

title "Verify BIG-IP availability"


# load data from Terraform output
# created by terraform output --json > bigip/files/terraform.json
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

BIGIP_DNS  = params['bigip_mgmt_public_ips']['value']
BIGIP_PORT = params['bigip_mgmt_port']['value']
BIGIP_PASSWORD  = params['bigip_password']['value']

control "Connectivity" do
  impact 1.0
  title "BIGIP is reachable"

  BIGIP_DNS.each do |bigip_host|
    # can we reach the management port on the BIG-IP?
    describe host(bigip_host, port: BIGIP_PORT, protocol: 'tcp') do
        it { should be_reachable }
    end
    # is the application services end point available?
    describe http("https://#{bigip_host}:#{BIGIP_PORT}/mgmt/shared/appsvcs/info",
              auth: {user: 'admin', pass: BIGIP_PASSWORD},
              params: {format: 'html'},
              method: 'GET',
              ssl_verify: false) do
          its('status') { should cmp 200 }
          its('body') { should match 'version' } # this should be replaced with a more nuanced set of tests
          its('headers.Content-Type') { should match 'application/json' }
    end
  end
end 



