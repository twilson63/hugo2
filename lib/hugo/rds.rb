module Hugo
  class Rds
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
    DEFAULT_SIZE = 5
    INSTANCE_CLASS = "db.m1.small"
    ZONE = "us-east-1c"
    
    def initialize(options={})
      # create instance
      
      self.server = options[:server] || options["DBInstanceIdentifier"]
      self.db = options[:db] || options["DBName"]
      self.user = options[:user] || options["MasterUsername"]
      self.pwd = options[:pwd] || "****"
      self.size = options[:size] || options["AllocatedStorage"] || DEFAULT_SIZE
      self.instance_class = options[:instance_class] || options["DBInstanceClass"] || INSTANCE_CLASS
      self.zone = options[:zone] || options["AvailabilityZone"] || ZONE
      self.status = options["DBInstanceStatus"] || "pending"
      self.create_time = options["InstanceCreateTime"] || nil
      if options["Endpoint"] and options["Endpoint"]["Address"]
        self.uri = options["Endpoint"]["Address"] || nil 
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
      
      true
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
      instance_desc = @rds.describe_db_instances(:db_instance_identifier => instance).DescribeDBInstancesResult.DBInstances.DBInstance
      # initialize Hugo::Rds Object with instance hash
      self.new(instance_desc)
    end
        
    
    def self.find_or_create(db)
      
    end

    def uri=(uri)
      @uri = uri
    end
    
    def uri
      @uri
    end

    def server=(server)
      @server = server
    end
    
    def server
      @server
    end

    def db=(db)
      @db = db
    end
    
    def db
      @db
    end

    def user=(user)
      @user = user
    end
    
    def user
      @user
    end
  
    def pwd=(pwd)
      @pwd = pwd
    end
    
    def pwd
      @pwd
    end

    def instance_class=(instance_class)
      @instance_class = instance_class
    end
    
    def instance_class
      @instance_class
    end

    def zone=(zone)
      @zone = zone
    end
    
    def zone
      @zone
    end

    def size=(size)
      @size = size
    end
    
    def size
      @size
    end  

    def status=(status)
      @status = status
    end
    
    def status
      @status
    end  

    def create_time=(create_time)
      @create_time = create_time
    end
    
    def create_time
      @create_time
    end
  end
  
end
