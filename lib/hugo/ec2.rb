module Hugo
  class Ec2
    
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY']
    KEY_NAME = ENV['KEY_NAME']
    
    AMI = ENV['EC2_AMI_ID'] || 'ami-1515f67c'
    ZONE = "us-east-1c"
    TYPE = "m1.small"
  
    attr_accessor :name, :uri, :type, :zone, :image_id, :key_name, :create_time, :status

    def initialize(options = {})
      @name = options["instanceId"] 
      
      if options["placement"] and options["placement"]["availabilityZone"]
        @zone = options["placement"]["availabilityZone"] 
      else
        @zone = ZONE
      end
      
      @uri = options["dnsName"] || ""
      @type = options["instanceType"] || TYPE
      @image_id = options["imageId"] || AMI
      @create_time = options["launchTime"] || nil
      
      @key_name = options["key_name"] || options["keyName"] || KEY_NAME
      if options["instanceState"] and options["instanceState"]["name"]
        @status = options["instanceState"]["name"]
      else
        @status = "unknown"
      end
    end
    
    def create
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.run_instances(:image_id => self.image_id, :key_name => self.key_name, 
        :max_count => 1,
        :availability_zone => self.zone) unless self.create_time
      self
    end
    
    def destroy
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.terminate_instances(:instance_id => self.name)
    end
    
    def save
      self.create
    end
    
    def ssh(commands, dna = nil)
      Net::SSH.start(self.uri, "ubuntu", :keys => self.key_name) do |ssh|
        if dna
          ssh.exec!("echo \"#{dna.to_json.gsub('"','\"')}\" > ~/dna.json")
        end
        commands.each do |cmd|
          puts ssh.exec!(cmd)
        end
      end
    end
    
    def find_or_create_security_group(name, description)
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      begin
        @security_groups = @ec2.describe_security_groups(:group_name => name)
      rescue
        @security_groups = @ec2.create_security_groups(:group_name => name, :group_description => description)
      end
      @security_groups
    end

    def destroy_security_group(name)
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.delete_security_group(:group_name => name)
    end

    def self.all
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @ec2.describe_instances().reservationSet.item[0].instancesSet.item.map { |i| self.new(i) }
    end
    
    def self.find(instance)
      @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      self.new(@ec2.describe_instances(:instance_id => instance).reservationSet.item[0].instancesSet.item[0])
    end
    
    def self.find_or_create(options)
      if options[:name]
        self.find(options[:name]) 
      else
        self.new(options).create
      end
    end
  end
end
