module Hugo
  module Aws
    class Rds
    
      ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
      SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
      DEFAULT_SIZE = 5
      INSTANCE_CLASS = "db.m1.small"
      ZONE = "us-east-1c"
    
      attr_accessor :db, :uri, :server, :user, :password, :instance_class, 
                    :zone, :size, :status, :create_time, :db_security_group,
                    :aws_access_key_id, :aws_secret_access_key
                    
                    
    
      def initialize(options={})
        # create instance
        
        @server = options[:server] || options["DBInstanceIdentifier"]
        @db = options[:name] #|| options["DBName"]
        @user = options[:user] || options["MasterUsername"]
        @password = options[:password] if options[:password]
        @size = options[:size] || options["AllocatedStorage"] || DEFAULT_SIZE
        @instance_class = options[:instance_class] || options["DBInstanceClass"] || INSTANCE_CLASS
        @zone = options[:zone] || options["AvailabilityZone"] || ZONE
        @status = options["DBInstanceStatus"] || "pending"
        @create_time = options["InstanceCreateTime"] || nil
        if options["Endpoint"] and options["Endpoint"]["Address"]
          @uri = options["Endpoint"]["Address"] || nil 
        end
        @db_security_group = options[:db_security_group] || "default"
        if options["DBSecurityGroups"] and options["DBSecurityGroups"]["DBSecurityGroup"]
          @db_security_group = options["DBSecurityGroups"]["DBSecurityGroup"]["DBSecurityGroupName"] 
        end
        @aws_access_key_id = options[:aws_access_key_id] || ACCESS_KEY
        @aws_secret_access_key = options[:aws_secret_access_key] || SECRET_KEY
        
      end
    
      def create
        
        rds.create_db_instance(
          :db_instance_identifier => self.server,
          :allocated_storage => self.size,
          :db_instance_class => self.instance_class,
          :engine => "MySQL5.1",
          :master_username => self.user,
          :master_user_password => self.password,
          :db_name => self.db,
          :availability_zone => self.zone
          #, :db_security_groups => @db_security_group
          ) unless self.create_time
        self
      end
    
      def save
        create 
      end
    
      def destroy
        rds.delete_db_instance(:db_instance_identifier => self.server, :skip_final_snapshot => true)
      end
    
      def self.all(aws_access_key_id, aws_secret_access_key)
        @rds = AWS::RDS::Base.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
        instances = @rds.describe_db_instances.DescribeDBInstancesResult.DBInstances.DBInstance
      
        if instances.kind_of?(Array)
          #instances.map { |i| self.get_from_aws(i) }
          instances.map { |i| self.new(i) }
        else
           #self.get_from_aws(instances)      
           [ self.new(instances) ]
        end
      end
    
      def self.find(instance, aws_access_key_id, aws_secret_access_key)
        # find instance
        @rds = AWS::RDS::Base.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
        @rds_instance = @rds.describe_db_instances(:db_instance_identifier => instance)
        instance_desc = @rds_instance.DescribeDBInstancesResult.DBInstances.DBInstance  
        # initialize Hugo::Rds Object with instance hash
        self.new(instance_desc)
      rescue
        # AWS Can't find db instance called ????
        nil
      end

      def self.find_or_create(options)
        rds = self.find(options[:server], options[:aws_access_key_id], options[:aws_secret_access_key]) || self.new(options).create
        rds.db = options[:name]
        rds.password = options[:password]
        rds
      end

      def authorize_security_group(db_sec, ec2_sec, owner_id)
        #@rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        rds.authorize_db_security_group(:db_security_group_name => db_sec, :ec2_security_group_name => ec2_sec, :ec2_security_group_owner_id => owner_id)
      end
    
      def find_or_create_db_security_group(name, description)
        #@rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        begin
          @security_groups = rds.describe_db_security_groups(:db_security_group_name => name)
        rescue
          @security_groups = rds.create_db_security_group(:db_security_group_name => name, :db_security_group_description => description)
        end
        #puts @security_groups
        @security_groups
      end

      def destroy_db_security_group(name)
        rds.delete_db_security_group(:db_security_group_name => name)
      end
    private
      def rds
        AWS::RDS::Base.new(
          :access_key_id => self.aws_access_key_id, 
          :secret_access_key => self.aws_secret_access_key)
      end
    end
  end
end
