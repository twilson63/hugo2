require File.dirname(__FILE__) + '/../../spec_helper'

describe Hugo::Rds do
  before(:each) do
    mock_ec2
    mock_elb
    mock_rds

  end
    
  it "should create a new instance" do    
    @hugo_rds = Hugo::Rds.new(:name => "myserver", :db => "mydb", :user => "user", :password => "password").should be_true
    @hugo_rds.save.should be_true
  end
  
  it "should return all" do
    Hugo::Rds.all.length.should == 1
  end
  # 
  it "should find rds instance" do        
    Hugo::Rds.find('test').should_not be_nil
  end
  
  it "should delete rds instance" do    
    Hugo::Rds.find('test').destroy
  end
  
  it "should provide uri" do
    Hugo::Rds.find('test').uri.should_not be_nil
  end

  it "should find or create db security group" do
    @rds = Hugo::Rds.find('i-12345678')
    @rds.find_or_create_db_security_group('test', 'test description').should_not be_empty
  end
  
  it "should destroy a db security group" do
    Hugo::Rds.find('i-12345678').destroy_db_security_group('test').should be_true
  end
  
  it "should authorize a ec2 security group" do
    @rds = Hugo::Rds.find('i-12345678')
    @rds.authorize_security_group('test', 'test', '12334').should_not be_empty
  end
end
