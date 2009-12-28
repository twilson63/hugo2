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
  
  it "should find or create instance" do
    as = Hugo::AppServer.instance
    as.name = "instance"
    as.deploy.should be_a_kind_of(Hugo::Ec2)
  end
  
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
  
    AWS::EC2::Base.stub!(:new).and_return(@mock)
  
  end
  
end