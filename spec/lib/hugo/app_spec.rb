require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo App" do
  before(:each) do
    mocks
  end
  
  it "should allow aws key and secret key overrides" do
    block = lambda do
      cloud "my_cloud" do 
        clear
        aws_access_key_id "12345"
        aws_secret_access_key "123456"

        database "my_db" do
          server "my_server"
          user "hello"
          password "world"
        end
        
        balancer
        
        app "testapp" do 
          clear
          key_name "ec2-keypair"
          key_path "~/.ec2"
          cookbook "git@github.com:jackhq/hugo-cookbooks.git"
          
          servers 0
        end
        #deploy
        #print
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
  end
  
  
  it "should be valid" do
    
    block = lambda do
      cloud "my_cloud" do 
        clear
        aws_access_key_id "12345"
        aws_secret_access_key "123456"
        
        database "my_db" do
          server "my_server"
          user "hello"
          password "world"
        end
        
        balancer
        
        app "testapp" do 
          clear
          
          key_name "ec2-keypair"
          key_path "~/.ec2"
          cookbook "git@github.com:jackhq/hugo-cookbooks.git"
          
          servers 0
        end
        #deploy
        #print
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end
  
  it "should raise error requiring key_name" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          clear
          aws_access_key_id "12345"
          aws_secret_access_key "123456"
        
          app "testapp" do 
            clear
            key_path "~/.ec2"
            cookbook "my_cookbook"
            run_list ["role[base_rack_apache]"]
          end 
          deploy         
        end        
      end
    end.should raise_error('app.key_name Required')
  end

  it "should raise error requiring key_path" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          clear
          aws_access_key_id "12345"
          aws_secret_access_key "123456"
        
          app "testapp" do 
            clear
            key_name "ec2-keypair"
            cookbook "my_cookbook"
            run_list ["role[base_rack_apache]"]
          end 
          deploy         
        end        
      end
    end.should raise_error('app.key_path Required')
  end

  it "should raise error requiring cookbook" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          clear
          aws_access_key_id "12345"
          aws_secret_access_key "123456"
        
          app "testapp" do 
            clear
            key_name "ec2-keypair"
            key_path "~/.ec2"
            run_list ["role[base_rack_apache]"]
          end 
          deploy         
        end        
      end
    end.should raise_error('app.cookbook Required')
  end
  
  it "should raise error requiring aws_access_key_id" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          clear
          aws_secret_access_key "123456"
        
          app "testapp" do 
            clear
            key_name "ec2-keypair"
            key_path "~/.ec2"
            cookbook "my_cookbook"
            run_list ["role[base_rack_apache]"]
          end 
          deploy         
        end        
      end
    end.should raise_error('app.aws_access_key_id Required')
  end

  it "should raise error requiring aws_secret_access_key" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          clear

          app "testapp" do 
            clear
            aws_access_key_id "12345"

            key_name "ec2-keypair"
            key_path "~/.ec2"
            cookbook "my_cookbook"
            run_list ["role[base_rack_apache]"]
          end 
          deploy         
        end        
      end
    end.should raise_error('app.aws_secret_access_key Required')
  end
  
  
  
  it "should save dna" do
    block = lambda do
      cloud "my_cloud" do 
        balancer
        app "testapp" do 
          add_recipe "s3fs", :s3 => {:bucket => "samIam"}
          servers 0
          #puts run_list
          #puts dna.inspect
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
    #puts @app.dna
  end
  

  it "should raise error for database block not wrapped in cloud block" do
    block = lambda do
      app "myapp" do end
    end
    
    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should not raise error for database block wrapped in cloud block" do
    block = lambda do
      cloud "mycloud" do
        app "myapp" do end
      end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
end

# describe Hugo::App do
#   before(:each) do
#     mocks
#   end
#   
# 
#   it "should create a new ec2 instance" do
#     
#     app = Hugo::App.instance
#     app.key_name "ec2-keypair"
# 
#     app.servers 1
#     app.name "mydb"
#     #app.deploy.should be_a_kind_of(Hugo::Aws::Rds)
#   end
#   
#   
# end
