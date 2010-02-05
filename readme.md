# Hugo (Cloud DSL) 0.1.10
<small>A simple dsl to deploy to the cloud</small>


## Install

  gem install hugo

## Requirements

First, you need a Amazon AWS Account

You need to configure you system to contain AWS info in environment variables.

Make sure you are enabled to generate ELB, RDS, and EC2.

Make sure you have a keypair generated for you AWS Account!

## What does it look like?

    # mycloud.rb
    require 'hugo'

    config = YAML.load_file("mycloud.yml")
    
    Hugo do
      cloud "mycloud" do
        
        database "sample_app_production" do
          server "company_server"
          user "admin"
          password "admin"
        end

        balancer
        
        app "sample_app" do
          key_name "my-keypair"
          key_path     "~/.ec2"
          cookbook "git://github.com/jackhq/hugo-cookbooks.git"          
          
          run_list ["role[base-rack-apache]"]

          add_recipe 'github_keys', :github => {  
                        :url => "git@github.com:twilson63", 
                        :publickey => config["github"]["publickey"], 
                        :privatekey => config["github"]["privatekey"]
                      }

          add_recipe 'apache2', :apache => { :listen_ports => ['8080'] }

          add_recipe 'packages', :package_list => config["package_list"]
          add_recipe 'gems', :gem_list => config["gem_list"]          
          
          add_recipe "hugo_deploy", :hugo => {
            :app => {
              :name => 'myapp',
              :branch => 'HEAD',
              :migrate => true,
              :migration_command => 'rake db:migrate'
              
            },
            :ssl => {
              :private => config['app']['ssl']['private']
              :public => config['app']['ssl']['public']
              :gd_bundle => config['app']['ssl']['public']
            },
            :web => { :port => '8080' }
          }
          
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
    
---

## Documentation

### Hugo

The Hugo object is a wrapper to use the DSL, all of the DSL code must be inside of the Hugo block

    Hugo do
      
      # All of your code goes here!
      
    end
    
### cloud [name]

The cloud object can take a name parameter that allows you to name your cloud and should have a block that defines what artifacts are in you cloud.

#### Current Artifacts:

* database
* balancer
* app

### database [name]

The database artifact currently uses AWS RDS server to deploy your mysql database, but the goal is that the database artiface will support multiple database server api's.

#### Methods

* zone
* server
* user
* password
* type [default AWS:RDS]

---

### balancer [name]

The balancer currently uses AWS ELB server to create a load balancer server, but the plans are to enable the artifact to support several options.

#### Methods

* name
* zone
* port - app server port _default_ [8080]
* ssl - app server ssl port _default_ [8443]
* web_port - lb server port _default_ [80]
* web_ssl - lb ssl server port _default_ [443]
* type _default_ [AWS:ELB]

----

### app [name]

The app artifact is a front end using chef-solo to deploy the application.  Chef is a powerful infrastructure deployment to and chef-solo is the command line version.  We use AWS:EC2 to build the server and then ssh to connect and configure the server with chef-solo.  Then we pull a cookbook down using git and pass chef-sole a json file pointing to the local cookbook.  Then we let chef-solo do the rest of the work.  The Chef Cookbook is made up of recipes.  Using the app artifact you can add recipes to your infrastructure deployment by using the "add_recipe" passing the name and the options in a hash.  This feature gives you a great deal of flexability for deploying your applications.  In the example above you see that we are passing the github keys, package list, and gem list, as well as other items.  We are really excited about this feature and it is proving effective to manage complex deployment strategies.

### Methods

* name
* key_name
* key_path
* cookbook
* run_list
* add_recipe

#### Key Name

key_name - name of the key pair that you use to access your amazon infrastructure
key_path - path where the file is located
cookbook - the github repository of the cookbook that you want to use.
run_list - the roles and recipes that you want chef-solo to run.
add_recipe - the name of the recipe and a hash of options and settings.


### Working with the source

When you pull the source you need to run the following:

    gem install bundler
    bundle install
    
    # Run Tests
    
    spec ./spec
    
    
