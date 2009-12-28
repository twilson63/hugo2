require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Balancer" do
  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do
        balancer do 
          zone = "test_zone"
          port = "test_port"
          web = "test_web"
          type = "test_type"
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
end