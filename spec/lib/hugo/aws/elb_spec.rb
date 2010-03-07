require File.dirname(__FILE__) + '/../../../spec_helper'

describe Hugo::Aws::Elb do
  before(:each) do
    mock_ec2
    mock_elb
    mock_rds

  end
      
  it "should create a new instance" do    
    @hugo_elb = Hugo::Aws::Elb.new(:name => "myserver")
    @hugo_elb.should_not be_nil
    @hugo_elb.save.should_not be_nil
  end
  # 
  it "should return all" do
    Hugo::Aws::Elb.all("1","2").length.should == 1
  end
  # # 
  it "should find elb instance" do        
    Hugo::Aws::Elb.find('test',"1","2").should_not be_nil
  end
  # 
  it "should delete elb instance" do    
    Hugo::Aws::Elb.find('test',"1","2").destroy.should_not be_nil
  end
  
  it "should add ec2 intance" do
    Hugo::Aws::Elb.find('test',"1","2").add('i-12345678').instances.length.should == 1
  end
  
  it "should remove ec2 instance" do
    Hugo::Aws::Elb.find('test',"1","2").remove('i-12345678').instances.length.should == 0
  end
  
end
