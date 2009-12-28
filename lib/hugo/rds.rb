module Hugo
  class Rds
    include Hugo::Base
    
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
    DEFAULT_SIZE = 5
    INSTANCE_CLASS = "db.m1.small"
    ZONE = "us-east-1c"
    
    attr_accessor :db, :uri, :server, :user, :pwd, :instance_class, 
                  :zone, :size, :status, :create_time
    
    def initialize(options={})
      # create instance
      
      @server = options[:server] || options["DBInstanceIdentifier"]
      @db = options[:name] || options["DBName"]
      @user = options[:user] || options["MasterUsername"]
      @pwd = options[:password] || "****"
      @size = options[:size] || options["AllocatedStorage"] || DEFAULT_SIZE
      @instance_class = options[:instance_class] || options["DBInstanceClass"] || INSTANCE_CLASS
      @zone = options[:zone] || options["AvailabilityZone"] || ZONE
      @status = options["DBInstanceStatus"] || "pending"
      @create_time = options["InstanceCreateTime"] || nil
      if options["Endpoint"] and options["Endpoint"]["Address"]
        @uri = options["Endpoint"]["Address"] || nil 
      end
      
    end
    
    def create
      @rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)      

      @rds.create_db_instance(
        :db_instance_identifier => self.server,
        :allocated_storage => self.size,
        :db_instance_class => self.instance_class,
        :engine => "MySQL5.1",
        :master_username => self.user,
        :master_user_password => self.pwd,
        :db_name => self.db,
        :availability_zone => self.zone) unless self.create_time
      
      self
    end
    
    def save
      self.create 
    end
    
    
    def destroy
      @rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)      

      @rds.delete_db_instance(:db_instance_identifier => self.server, :skip_final_snapshot => true)
      
    end
    
    
    
    def self.all
      @rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      instances = @rds.describe_db_instances.DescribeDBInstancesResult.DBInstances.DBInstance
      
      if instances.kind_of?(Array)
        #instances.map { |i| self.get_from_aws(i) }
        instances.map { |i| self.new(i) }
      else
         #self.get_from_aws(instances)      
         [ self.new(instances) ]
      end
      
    end
    
    def self.find(instance)
      # find instance
      @rds = AWS::RDS::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @rds_instance = @rds.describe_db_instances(:db_instance_identifier => instance)
      instance_desc = @rds_instance.DescribeDBInstancesResult.DBInstances.DBInstance  
      # initialize Hugo::Rds Object with instance hash
      self.new(instance_desc)
    rescue
      # AWS Can't find db instance called ????
      nil
    end
    
  end
end
