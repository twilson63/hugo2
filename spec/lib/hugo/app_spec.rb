require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo App" do
  before(:each) do
    mocks
  end
  
  it "should be valid" do
    
    block = lambda do
      cloud "my_cloud" do 
        balancer
        app "testapp" do 
          servers 0
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
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
