# Hugo (Cloud DSL)
<small>A simple dsl to deploy to the cloud</small>

Currently only supports Amazon Web Services, but will be expanded soon!

## Requirements

First, you need a Amazon AWS Account

You need to configure you system to contain AWS info in environment variables.

Make sure you are enabled to generate ELB, RDS, and EC2.

Make sure you have a keypair generated for you AWS Account!

## What does it look like?

    Hugo do
      cloud "mycloud" do
        balancer
        
        database "sample_app_production" do
          server "company_server"
          user "admin"
          password "admin"
        end
        
        app "sample_app" do
          key_name "my-keypair"
          servers 2
          
          cookbook "git://github.com/twilson63/hugo-cookbooks.git"
          
          setup
          
          key_pair_file     "~/.ec2/my-keypair"
          port              "8080"
          github_url        "git@github.com:twilson63"
          privatekey        config["github"]["privatekey"]
          publickey         config["github"]["publickey"]
          package_list      config["package_list"]
          gem_list          config["gem_list"]
          run_list          ["role[web-base]", "role[web-app]"]
          
          deploy_info :web_server_name => "sample_app.jackhq.com",
              :restart_command => "gem bundle && touch tmp/restart.txt" 
          
        end
      end
