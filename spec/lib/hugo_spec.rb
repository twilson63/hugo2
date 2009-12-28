require File.dirname(__FILE__) + '/../spec_helper'

describe "Hugo DSL" do
  it "should be valid" do
    block = lambda {|a,b|}
    lambda do
      Hugo &block
    end.should be_true
  end
  

  it "should be_true with cloud block" do
    block = lambda do
      cloud "my_cloud" do end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
  
  it "should attach app servers to balancer" do
    block = lambda do
      cloud "mycloud" do 
        
        b = balancer do
        
        end
        
        1.times do
          a = app_server do
          
          
          end
          b.attach(a.name)
        end
        
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
    
    
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
    
    @mock2 = mock('AWS::ELB::Base')
    instance = {"DescribeLoadBalancersResult"=>
        {"LoadBalancerDescriptions"=>
          {"member"=>[
            {"CreatedTime"=>"2009-11-27T17:23:31.890Z", "Listeners"=>
              {"member"=>[
                {"InstancePort"=>"8080", "Protocol"=>"HTTP", "LoadBalancerPort"=>"80"}, 
                {"InstancePort"=>"8443", "Protocol"=>"TCP", "LoadBalancerPort"=>"443"}]}, 
              "HealthCheck"=>{"HealthyThreshold"=>"10", "Timeout"=>"5", "UnhealthyThreshold"=>"2", "Interval"=>"30", "Target"=>"TCP:8080"}, 
              "AvailabilityZones"=>{"member"=>["us-east-1c"]}, 
              "DNSName"=>"test-611935247.us-east-1.elb.amazonaws.com", 
              "LoadBalancerName"=>"test", 
              "Instances"=>{"member"=>[{"InstanceId"=>"i-XX14642f"}, {"InstanceId"=>"i-YY5b2923"}]}}]}}, 
              "ResponseMetadata"=>{"RequestId"=>"0ada795e-e1df-11de-950d-c1b3b9142192"}, "xmlns"=>"http://elasticloadbalancing.amazonaws.com/doc/2009-05-15/"}
    
    @mock2.stub!(:create_load_balancer).and_return(instance)
    @mock2.stub!(:describe_load_balancers).and_return(instance)
    @mock2.stub!(:delete_load_balancer).and_return(instance)
    @mock2.stub!(:register_instances_with_load_balancer).and_return(instance)
    @mock2.stub!(:deregister_instances_from_load_balancer).and_return(instance)

    AWS::ELB::Base.stub!(:new).and_return(@mock2)
    
  end
  
end