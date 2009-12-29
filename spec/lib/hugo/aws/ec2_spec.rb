require File.dirname(__FILE__) + '/../../../spec_helper'

describe Hugo::Aws::Ec2 do
  before(:each) do
    @mock = mock('AWS::EC2::Base')
    instance = {"requestId"=>"e280b5aa-9b60-458f-b16f-96f97eb5e628", "reservationSet"=>
      {"item"=>[{"reservationId"=>"r-ff5d8797", "groupSet"=>{"item"=>[{"groupId"=>"default"}]}, 
                "instancesSet"=>{"item"=>[{"privateIpAddress"=>"10.210.43.6", "keyName"=>"ec2-keypair", "ramdiskId"=>"ari-0915f660", "productCodes"=>nil, "ipAddress"=>"174.129.63.98", "kernelId"=>"aki-5f15f636", "launchTime"=>"2009-11-29T13:20:48.000Z", "amiLaunchIndex"=>"0", 
                "imageId"=>"ami-1515f67c", "instanceType"=>"m1.small", "reason"=>nil, "placement"=>{"availabilityZone"=>"us-east-1c"}, 
                "instanceId"=>"i-12345678", "privateDnsName"=>"domU-XXXX.compute-1.internal", 
                "dnsName"=>"ec2-XXX.compute-1.amazonaws.com", "monitoring"=>{"state"=>"enabled"}, 
                "instanceState"=>{"name"=>"running", "code"=>"16"}}]}, "ownerId"=>"398217953086"}]}, "xmlns"=>"http://ec2.amazonaws.com/doc/2009-07-15/"}
    
    @mock.stub!(:run_instances).and_return(instance)
    @mock.stub!(:describe_instances).and_return(instance)
    @mock.stub!(:terminate_instances).and_return(instance)
  
    security_group = {"group_name"=>"test", "group_description"=>"test description"}
    @mock.stub!(:create_security_groups).and_return(security_group)
    @mock.stub!(:describe_security_groups).and_return(security_group)
    @mock.stub!(:delete_security_group).and_return(security_group)
  
    AWS::EC2::Base.stub!(:new).and_return(@mock)
  end
        
  it "should create a new instance" do  
    @ec2 = Hugo::Aws::Ec2.new()
    @ec2.save.should be_true  
  end

  it "should terminate instance" do
    Hugo::Aws::Ec2.find('i-12345678').destroy.should be_true
  end

  it "should find instance" do
    Hugo::Aws::Ec2.find('i-12345678').should_not be_nil
  end

  it "should return all instances" do
    Hugo::Aws::Ec2.all.length.should == 1
  end
  
  it "should find or create security group" do
    @ec2 = Hugo::Aws::Ec2.find('i-12345678')
    @ec2.find_or_create_security_group('test', 'test description').should_not be_empty
  end
  
  it "should destroy a security group" do
    Hugo::Aws::Ec2.find('i-12345678').destroy_security_group('test').should be_true
  end
  #
  # it "should deploy app" do
  #   
  # end
  # 
end