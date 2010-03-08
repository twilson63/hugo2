require File.dirname(__FILE__) + '/../../../spec_helper'

describe Hugo::Aws::Rds do
  before(:each) do
    mock_ec2
    mock_elb
    mock_rds
  end
    
  it "should create a new instance" do    
    @hugo_rds = Hugo::Aws::Rds.new(
      :name => "myserver", 
      :db => "mydb", 
      :user => "user", 
      :password => "password",
      :aws_access_key_id => '12',
      :aws_secret_access_key => '12')
    @hugo_rds.should_not be_nil
    @hugo_rds.save.should be_true
  end
  
  it "should return all" do
    Hugo::Aws::Rds.all('12','34').length.should == 1
  end
  # 
  it "should find rds instance" do        
    Hugo::Aws::Rds.find('test','12','34').should_not be_nil
  end
  
  it "should delete rds instance" do    
    Hugo::Aws::Rds.find('test','12','34').destroy
  end
  
  it "should provide uri" do
    Hugo::Aws::Rds.find('test','12','34').uri.should_not be_nil
  end

  # it "should find or create db security group" do
  #   @rds = Hugo::Aws::Rds.find('i-12345678','12','34')
  #   @rds.find_or_create_db_security_group('test', 'test description').should_not be_empty
  # end
  
  # it "should destroy a db security group" do
  #   Hugo::Aws::Rds.find('i-12345678').destroy_db_security_group('test').should be_true
  # end
  
  # it "should authorize a ec2 security group" do
  #   @rds = Hugo::Aws::Rds.find('i-12345678','12','34')
  #   @rds.authorize_security_group('test', 'test', '12334').should_not be_empty
  # end
end
