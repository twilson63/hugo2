require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Database" do
  before(:each) do
    mocks
  end

  it "should raise error requiring user" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          database "testapp" do 
            clear
            server "server"
            password "test_password"
          end          
        end        
      end
    end.should raise_error('database.user Required')
  end

  it "should raise error requiring password" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          database "testapp" do
            clear
            server "server"
            user "test_user"
          end          
        end        
      end
    end.should raise_error('database.password Required')
  end

  it "should raise error requiring server" do
    lambda do
      Hugo do
        cloud "my_cloud" do
          database "testapp" do
            clear
            password "test_password"
            user "test_user"
          end          
        end        
      end
    end.should raise_error('database.server Required')
  end

  it "should be valid" do
        
    lambda do
      Hugo do
        cloud "my_cloud" do 
          database "testapp" do 
            server "serverx"
            user "test_user"
            password "test_password"
          end
        end
      end
    end.should_not raise_error
  end

  it "should raise error for database block not wrapped in cloud block" do
    lambda do
      Hugo { database "mydb" }
    end.should raise_error
  end

  it "should not raise error for database block wrapped in cloud block" do
    lambda do
      Hugo do
        cloud "mycloud" do
          database "mydb" do end
        end      
      end
    end.should be_true
  end
end
# 
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
    db.deploy.should be_a_kind_of(Hugo::Database)
  end
  
  it "should clear required attributes" do
    db = Hugo::Database.instance
    db.server "myserver"
    db.name "mydb"
    db.user "admin"
    db.password "test"
    db.clear
    db.server.should be_nil
    db.user.should be_nil
    db.password.should be_nil
    
  end
  
  it "should print help for database" do
    db = Hugo::Database.instance
    db.name "myserver"
    db.help.should =~ /^Welcome to Hugo/
    
  end
  
  it "should return an info hash" do
    db = Hugo::Database.instance
    db.server "myserver"
    db.name "mydb"
    db.user "admin"
    db.password "test"
    db.deploy
    db.info.inspect.should == '{:password=>"test", :user=>"user", :name=>"mydb", :uri=>"test.cwrzj6lxowfj.us-east-1.rds.amazonaws.com"}'
  end
  
  
  
end
  
