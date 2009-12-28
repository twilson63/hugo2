require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo App Server" do
  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do
        app_server do 
        end
      end
    end

    lambda do
      Hugo &block
    end.should_not raise_error
  end

  it "should raise error for app_server block not wrapped in cloud block" do
    block = lambda do
      app_server "error" do end
    end
    
    lambda do
      Hugo &block
    end.should raise_error
  end
end