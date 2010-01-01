# Hugo (Cloud DSL)
<small>A simple dsl to deploy to the cloud</small>

Currently only supports Amazon Web Services, but will be expanded soon!

## Requirements

First, you need a Amazon AWS Account

You need to configure you system to contain AWS info in environment variables.

Make sure you are enabled to generate ELB, RDS, and EC2.

Make sure you have a keypair generated for you AWS Account!

## What does it look like?

    # mycloud.rb
    require 'lib/hugo'

    config = YAML.load_file("mycloud.yml")
    
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
          
          cookbook "git://github.com/twilson63/hugo-cookbooks.git"          
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

          servers 2
          
        end
        
        deploy
        
        print
      end

---

## What about the config file?

    # mycloud.yml
    
    github:
      url: XXXX
      publickey: XXX
      privatekey: XXX

    package_list:
      - name: mysql-client
      - name: libmysqlclient15-dev    
      - name: libmysql-ruby1.8
      - name: libexpat1
      - name: libxml2
      - name: libxml2-dev
      - name: libxslt1-dev
      - name: sqlite3
      - name: libsqlite3-dev

    gem_list:
      - name: bundler
    
    