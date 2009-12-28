require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Database" do
  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do
        database do 
          user = "test_user"
          password = "test_password"
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end

  it "should raise error for database block not wrapped in cloud block" do
    block = lambda do
      database "my_db" do end
    end
    
    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should not raise error for database block wrapped in cloud block" do
    block = lambda do
      cloud "my_cloud" do
        database "my_db" do end
      end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
end