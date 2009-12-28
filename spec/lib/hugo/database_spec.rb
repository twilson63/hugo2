require File.dirname(__FILE__) + '/../../spec_helper'

describe "Hugo Database" do
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

  it "should be valid" do
    
    block = lambda do
      cloud "my_cloud" do
        database "eirene4" do 
          server = "serverx"
          user = "test_user"
          password = "test_password"
        end
      end
    end
    
    lambda do
      Hugo &block
    end.should_not raise_error
  end

  it "should raise error for database block not wrapped in cloud block" do
    block = lambda do
      database "mydb" do end
    end
    
    lambda do
      Hugo &block
    end.should raise_error
  end

  it "should not raise error for database block wrapped in cloud block" do
    block = lambda do
      cloud "mycloud" do
        database "mydb" do end
      end
    end
    
    lambda do
      Hugo &block
    end.should be_true
  end
end

describe Hugo::Database do
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
  
  

  it "should create a new rds instance" do
    
    db = Hugo::Database.instance
    db.server = "myserver"
    db.name = "mydb"
    db.user = "admin"
    db.password = "test"
    db.deploy.should be_a_kind_of(Hugo::Rds)
  end
  
  
end
  