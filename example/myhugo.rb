require '../lib/hugo'

Hugo do
 cloud "client" do
   @instances = 2
   @application = "example"

   database do
     @user = "dbsa"
     @pass = "dbpass"
   end

   balancer

   @package_list = [{"name"=>"mysql-client"}]
   @gem_list = [{"name"=>"rack"}, {"name"=>"rails", "version"=>"2.3.5"}]
   @run_list = ["role[web-app]"]

   @github_url = "git@github.com:example"
   @privatekey = "-----BEGIN RSA PRIVATE KEY-----\nxxxxxx-------\n-----END RSA PRIVATE KEY-----\n"
   @publickey = "ssh-rsa xxxxxxxxx== progger@example.com\n"

   @app_info = { :branch => "master", :migrate => true }
 end
end