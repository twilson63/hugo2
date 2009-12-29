require File.dirname(__FILE__) + '/../../spec_helper'

describe Hugo::Elb do
  before(:each) do
    mock_ec2
    mock_elb
    mock_rds


  end
      
  it "should create a new instance" do    
    @hugo_elb = Hugo::Elb.new(:name => "myserver").should be_true
    @hugo_elb.save.should be_true
  end
  # 
  it "should return all" do
    Hugo::Elb.all.length.should == 1
  end
  # # 
  it "should find elb instance" do        
    Hugo::Elb.find('test').should_not be_nil
  end
  # 
  it "should delete elb instance" do    
    Hugo::Elb.find('test').destroy.should_not be_nil
  end
  
  it "should add ec2 intance" do
    Hugo::Elb.find('test').add('i-12345678').instances.length.should == 3
  end
  
  it "should remove ec2 instance" do
    Hugo::Elb.find('test').remove('i-12345678').instances.length.should == 2
  end

  # it "should provide uri" do
  #   Hugo::Elb.find('test').uri.should_not be_nil
  # end
  
  # it "should provide Created Date"
  # it "should find or create rds instance"
end
