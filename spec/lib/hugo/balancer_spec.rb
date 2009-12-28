require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Balancer" do

  it "should be valid" do
    block = lambda do
      cloud "my_cloud" do
        balancer do 
          zone = "test_zone"
          port = "test_port"
          web = "test_web"
          type = "test_type"
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end

  it "should raise error for balancer block not wrapped in cloud block" do
    block = lambda do
      balancer "error" do end
    end

    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should find or create balancer" do
    lb = Hugo::Balancer.instance
    lb.name = "myserver"
    lb.deploy.should be_a_kind_of(Hugo::Elb)
  end

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

end