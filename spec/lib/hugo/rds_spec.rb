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
  
  # it "should provide Created Date"
  # it "should find or create rds instance"
end
