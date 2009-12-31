require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Database" do
  before(:each) do
    mocks
  end

  it "should be valid" do
    
    block = lambda do
      cloud "my_cloud" do 
        database "testapp" do 
          server "serverx"
          user "test_user"
          password "test_password"
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end

  it "should raise error for database block not wrapped in cloud block" do
    block = lambda do
      database "mydb" do end
    end
    
    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should not raise error for database block wrapped in cloud block" do
    block = lambda do
      cloud "mycloud" do
        database "mydb" do end
      end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
end

describe Hugo::Database do
  before(:each) do
    mocks
  end
  

  it "should create a new rds instance" do
    
    db = Hugo::Database.instance
    db.server "myserver"
    db.name "mydb"
    db.user "admin"
    db.password "test"
    db.deploy.should be_a_kind_of(Hugo::Aws::Rds)
  end
  
  
end
  