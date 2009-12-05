require File.dirname(__FILE__) + '/../spec_helper'

describe Hugo::Rds do
  before(:each) do
    @mock = mock('AWS::RDS::Base')
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
            "AvailabilityZone"=>"us-east-1c", "DBSecurityGroups"=>{ "DBSecurityGroup"=>{"Status"=>"active", "DBSecurityGroupName"=>"default"}}, "DBParameterGroups"=>{"DBParameterGroup"=>{"DBParameterGroupName"=>"default.mysql5.1", "ParameterApplyStatus"=>"in-sync"}}, "PreferredBackupWindow"=>"03:00-05:00" 
          }
        } 
      }
    }
    
    @mock.stub!(:create_db_instance).and_return(instance)
    @mock.stub!(:describe_db_instances).and_return(instance)
    @mock.stub!(:delete_db_instance).and_return(instance)

    AWS::RDS::Base.stub!(:new).and_return(@mock)

  end
    
  it "should create a new instance" do    
    @hugo_rds = Hugo::Rds.new(:server => "myserver", :db => "mydb", :user => "user", :pwd => "password").should be_true
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
