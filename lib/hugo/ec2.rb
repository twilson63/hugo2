module Hugo
  class Ec2
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY']
    KEY_NAME = ENV['KEY_NAME']
    
    AMI = ENV['EC2_AMI_ID'] || 'ami-1515f67c'
    ZONE = "us-east-1c"
    TYPE = "m1.small"
    
  
    def initialize(options = {})
      self.name = options["instanceId"] 
      
      if options["placement"] and options["placement"]["availabilityZone"]
        self.zone = options["placement"]["availabilityZone"] 
      else
        self.zone = ZONE
      end
      
      self.uri = options["dnsName"] || ""
      self.type = options["instanceType"] || TYPE
      self.image_id = options["imageId"] || AMI
      self.create_time = options["launchTime"] || nil
      
      self.key_name = options["key_name"] || options["keyName"] || KEY_NAME
      if options["instanceState"] and options["instanceState"]["name"]
        self.status = options["instanceState"]["name"]
      else
        self.status = "unknown"
      end
    end
    
    def create
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.run_instances(:image_id => self.image_id, :key_name => self.key_name, 
        :max_count => 1,
        :availability_zone => self.zone) unless self.create_time
    end
    
    def destroy
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.terminate_instances(:instance_id => self.name)
    end
    
    def save
      self.create
    end
    
    def self.all
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.describe_instances().reservationSet.item[0].instancesSet.item.map { |i| self.new(i) }
      
    end
    
    def self.find(instance)
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      self.new(@ec2.describe_instances(:instance_id => instance).reservationSet.item[0].instancesSet.item[0])
    
    end
    
    def name
      @name
    end
    
    def name=(name)
      @name = name
    end
    
    def uri
      @uri
    end
    
    def uri=(uri)
      @uri = uri
    end

    def zone
      @zone
    end
    
    def zone=(zone)
      @zone = zone
    end

    def type
      @type
    end
    
    def type=(type)
      @type = type
    end

    def image_id
      @image_id
    end
    
    def image_id=(image_id)
      @image_id = image_id
    end

    def key_name
      @key_name
    end
    
    def key_name=(key_name)
      @key_name = key_name
    end
    
    def create_time
      @create_time
    end
    
    def create_time=(create_time)
      @create_time = create_time
    end

    def status
      @status
    end
    
    def status=(status)
      @status = status
    end
    
  end
  
end
