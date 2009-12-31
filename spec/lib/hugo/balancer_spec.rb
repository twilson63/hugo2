require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Balancer" do
  before(:each) do
    mocks
  end

  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do 
        balancer
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
    lb.deploy.should be_a_kind_of(Hugo::Aws::Elb)
    
  end

end