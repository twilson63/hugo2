require File.dirname(__FILE__) + '/../spec_helper'

describe "Hugo DSL" do
  before(:each) do
    mocks        
  end
  
  it "should be valid" do
    block = lambda {|a,b|}
    lambda do
      Hugo &block
    end.should be_true
  end
  

  it "should be_true with cloud block" do
    block = lambda do
      cloud "my_cloud" do end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
  
  it "should deploy a single server app" do
    block = lambda do
      cloud "my_cloud" do                         
        database "db_name" do 
          server     "db_server"
          user       "admin"
          password   "mypassword"  
        end
        
        balancer 
        
        app "app_name" do
          
                            
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should be_true
 
  end
  
  
  
  
  it "should deploy infrastructure" do
    block = lambda do
      
      cloud "gmms" do                 
        aws_access_key_id "12345"
        aws_secret_access_key "123456"
        
        balancer 
        
        database "sentinel" do 
          server     "jackhq"
          user       "admin"
          password   "mypassword"  
        end
        
        app "sentinel" do
          gem_list = [{:name => "rack"}]                  
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
    
  end

  
end