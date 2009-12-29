require File.expand_path(File.dirname(__FILE__) + "/../lib/hugo")

Bundler.require_env(:test)    # get rspec and webrat in here


# require 'rubygems'
# require 'sinatra'
#require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

def mock_ssh
  @mock_ssh = mock('Net::SSH')
  Net::SSH.stub!(:start).and_return(@mock_ssh)
  @mock_ssh.stub!(:exec).and_return("Works!")  
end


def mock_ec2
  @mock_ec2 = mock('AWS::EC2::Base')
  instance = {"requestId"=>"e280b5aa-9b60-458f-b16f-96f97eb5e628", "reservationSet"=>
    {"item"=>[{"reservationId"=>"r-ff5d8797", "groupSet"=>{"item"=>[{"groupId"=>"default"}]}, 
              "instancesSet"=>{"item"=>[{"privateIpAddress"=>"10.210.43.6", "keyName"=>"ec2-keypair", "ramdiskId"=>"ari-0915f660", "productCodes"=>nil, "ipAddress"=>"174.129.63.98", "kernelId"=>"aki-5f15f636", "launchTime"=>"2009-11-29T13:20:48.000Z", "amiLaunchIndex"=>"0", 
              "imageId"=>"ami-1515f67c", "instanceType"=>"m1.small", "reason"=>nil, "placement"=>{"availabilityZone"=>"us-east-1c"}, 
              "instanceId"=>"i-12345678", "privateDnsName"=>"domU-XXXX.compute-1.internal", 
              "dnsName"=>"ec2-XXX.compute-1.amazonaws.com", "monitoring"=>{"state"=>"enabled"}, 
              "instanceState"=>{"name"=>"running", "code"=>"16"}}]}, "ownerId"=>"398217953086"}]}, "xmlns"=>"http://ec2.amazonaws.com/doc/2009-07-15/"}
  
  @mock_ec2.stub!(:run_instances).and_return(instance)
  @mock_ec2.stub!(:describe_instances).and_return(instance)
  @mock_ec2.stub!(:terminate_instances).and_return(instance)

  AWS::EC2::Base.stub!(:new).and_return(@mock_ec2)
  
end

def mock_elb
  @mock_elb = mock('AWS::ELB::Base')
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
            "Instances"=>{"member"=>[]}}]}}, 
            "ResponseMetadata"=>{"RequestId"=>"0ada795e-e1df-11de-950d-c1b3b9142192"}, "xmlns"=>"http://elasticloadbalancing.amazonaws.com/doc/2009-05-15/"}
  
  @mock_elb.stub!(:create_load_balancer).and_return(instance)
  @mock_elb.stub!(:describe_load_balancers).and_return(instance)
  @mock_elb.stub!(:delete_load_balancer).and_return(instance)
  @mock_elb.stub!(:register_instances_with_load_balancer).and_return(instance)
  @mock_elb.stub!(:deregister_instances_from_load_balancer).and_return(instance)

  AWS::ELB::Base.stub!(:new).and_return(@mock_elb)
  
  
end

def mock_rds
  @mock_rds = mock('AWS::RDS::Base')
  instance = { "DescribeDBInstancesResult" => 
    { "DBInstances" => 
      { "DBInstance" => 
        { "InstanceCreateTime"=>"2009-11-08T15:01:32.490Z", "Endpoint"=> { "Port"=>"3306", "Address"=>"test.cwrzj6lxowfj.us-east-1.rds.amazonaws.com"}, 
          "PreferredMaintenanceWindow"=>"sun:05:00-sun:09:00", 
          "DBName"=>"mydb", 
          "Engine"=>"mysql5.1", "MasterUsername"=>"user", 
          "DBInstanceClass"=>"db.m1.small", "DBInstanceStatus"=>"available", 
          "BackupRetentionPeriod"=>"1", "LatestRestorableTime"=>"2009-12-05T18:19:59Z", 
          "DBInstanceIdentifier"=>"myserver", "AllocatedStorage"=>"5", 
          "AvailabilityZone"=>"us-east-1c", 
          "DBSecurityGroups"=>{ "DBSecurityGroup"=>{"Status"=>"active", "DBSecurityGroupName"=>"default"}}, "DBParameterGroups"=>{"DBParameterGroup"=>{"DBParameterGroupName"=>"default.mysql5.1", "ParameterApplyStatus"=>"in-sync"}}, "PreferredBackupWindow"=>"03:00-05:00" 
        }
      } 
    }
  }
  
  create_db_security_group = {"CreateDBSecurityGroupResult"=>{"DBSecurityGroup"=>{"OwnerId"=>"XXXXXXXXXXXXXXX", "DBSecurityGroupName"=>"beer", "IPRanges"=>nil, "DBSecurityGroupDescription"=>"A light beverage", "EC2SecurityGroups"=>nil}}, "ResponseMetadata"=>{"RequestId"=>"cc934f2f-f4a9-11de-ba6b-0ba63aeeddfe"}, "xmlns"=>"http://rds.amazonaws.com/admin/2009-10-16/"}
  describe_db_security_groups = {"DescribeDBSecurityGroupsResult"=>{"DBSecurityGroups"=>{"DBSecurityGroup"=>{"OwnerId"=>"XXXXXXXXXXXX", "DBSecurityGroupName"=>"beer", "IPRanges"=>nil, "DBSecurityGroupDescription"=>"A light beverage", "EC2SecurityGroups"=>{"EC2SecurityGroup"=>{"Status"=>"authorized", "EC2SecurityGroupName"=>"default", "EC2SecurityGroupOwnerId"=>"XXXXXXXXXXXX"}}}}}, "ResponseMetadata"=>{"RequestId"=>"XXXXXXXXX"}, "xmlns"=>"http://rds.amazonaws.com/admin/2009-10-16/"}
  db_authorize_security_group = {"AuthorizeDBSecurityGroupIngressResult"=>{"DBSecurityGroup"=>{"OwnerId"=>"XXXXXXXXXXXXXX", "DBSecurityGroupName"=>"beer", "IPRanges"=>nil, "DBSecurityGroupDescription"=>"A light beverage", "EC2SecurityGroups"=>{"EC2SecurityGroup"=>{"Status"=>"authorizing", "EC2SecurityGroupName"=>"default", "EC2SecurityGroupOwnerId"=>"XXXXXXXXXX"}}}}, "ResponseMetadata"=>{"RequestId"=>"5920e8b0-f4aa-11de-8dc1-73435d6ae588"}, "xmlns"=>"http://rds.amazonaws.com/admin/2009-10-16/"}
  delete_db_security_group = {"ResponseMetadata"=>{"RequestId"=>"2e4f133b-f4ac-11de-bce4-4f8690d51058"}, "xmlns"=>"http://rds.amazonaws.com/admin/2009-10-16/"}
  
  @mock_rds.stub!(:create_db_instance).and_return(instance)
  @mock_rds.stub!(:describe_db_instances).and_return(instance)
  @mock_rds.stub!(:delete_db_instance).and_return(instance)
  @mock_rds.stub!(:create_db_security_group).and_return(create_db_security_group)
  @mock_rds.stub!(:authorize_db_security_group).and_return(db_authorize_security_group)
  @mock_rds.stub!(:delete_db_security_group).and_return(delete_db_security_group)
  @mock_rds.stub!(:describe_db_security_groups).and_return(describe_db_security_groups)

  AWS::RDS::Base.stub!(:new).and_return(@mock_rds)
  
end

def mocks
  mock_ssh
  mock_ec2
  mock_rds
  mock_elb
end




