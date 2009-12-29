require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Balancer" do

  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do 
        @instances = 1
        balancer do end
        database "testapp" do 
          @server = "serverx"
          @user = "test_user"
          @password = "test_password"
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
    lb.name = "myserver"
    lb.deploy.should be_a_kind_of(Hugo::Elb)
    
  end

  before(:each) do
    mock_ec2
    mock_elb
    mock_rds
  end

end