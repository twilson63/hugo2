require 'lib/hugo'

config = YAML.load_file("oregano.yml")

Hugo do
  cloud "oregano" do
    balancer
    
    app "oregano" do
      @key_name = "ec2-keypair"
      servers 1
      @cookbook = "git://github.com/twilson63/hugo-cookbooks.git"
      #setup
      @key_pair_file = "~/.ec2/ec2-keypair"
      @port = "8080"
            
      @github_url = "git@github.com:twilson63"
      @privatekey = config["github"]["privatekey"]
      @publickey = config["github"]["publickey"]
      @package_list = config["package_list"]
      @gem_list = config["gem_list"]
            
            
      @run_list = ["role[web-base]", "role[web-app]"]
      @deploy_info = { }
      
      deploy
    end
    
    print
  end
  
end
