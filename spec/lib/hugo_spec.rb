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
  
  
  
  it "should deploy infrastructure" do
    block = lambda do
      
      cloud "gmms" do 
        @application = "sentinel"
        @instances   =  2
                
        balancer do 
          
        end
        
        database "sentinel" do 
          @user       =  "admin"
          @password   =  "mypassword"  
        end
        
        
        @gem_list = [{:name => "rack"}]                  
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
    
  end

  
end