require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Balancer" do
  before(:each) do
    mocks
  end

  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do 
        balancer do
          aws_access_key_id "12345"
          aws_secret_access_key "123456"
          
        end
        
        
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end
  

  it "should raise error for balancer block not wrapped in cloud block" do
    block = lambda do
      balancer "error" do end
    end

    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should find or create balancer" do
    lb = Hugo::Balancer.instance
    lb.name "myserver"
    lb.aws_access_key_id "12"
    lb.aws_secret_access_key "12"
    lb.deploy.should be_a_kind_of(Hugo::Aws::Elb)
    
  end

  it "should print help for balancer" do
    lb = Hugo::Balancer.instance
    lb.name "myserver"
    lb.help.should =~ /^Hugo balancer/
    
  end

end