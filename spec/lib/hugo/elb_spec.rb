require File.dirname(__FILE__) + '/../../spec_helper'

describe Hugo::Elb do
  before(:each) do
    @mock = mock('AWS::ELB::Base')
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
    
    @mock.stub!(:create_load_balancer).and_return(instance)
    @mock.stub!(:describe_load_balancers).and_return(instance)
    @mock.stub!(:delete_load_balancer).and_return(instance)
    @mock.stub!(:register_instances_with_load_balancer).and_return(instance)
    @mock.stub!(:deregister_instances_from_load_balancer).and_return(instance)

    AWS::ELB::Base.stub!(:new).and_return(@mock)

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
