require File.dirname(__FILE__) + '/../spec_helper'

describe "Hugo DSL" do
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
  
  it "should deploy infrastructure" do
    block = lambda do
      cloud "mycloud" do 
        @application =  "blank"
        @instances   =  2
                
        balancer      do end
        
        
        database "tomtest" do 
          @server     =  "jackdev"
          @user       =  "admin"
          @password   =  "mypassword"  
        end
                          
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
    
  end

  before(:each) do
    mock_ec2
    mock_elb
    mock_rds
        
  end
  
end