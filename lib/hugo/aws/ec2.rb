module Hugo
  module Aws
    class Ec2
    
      ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
      SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY']
      KEY_NAME = ENV['KEY_NAME']
    
      AMI = ENV['EC2_AMI_ID'] || 'ami-1515f67c'
      ZONE = "us-east-1c"
      TYPE = "m1.small"
  
      attr_accessor :name, :uri, :type, :zone, :image_id, :key_name, :create_time, :status, :security_group

      def initialize(options = {})
        set_attributes(options)
      end
      
      def set_attributes(options = {})
        @name = options["instanceId"] 
      
        if options["placement"] and options["placement"]["availabilityZone"]
          @zone = options["placement"]["availabilityZone"] 
        elsif options[:zone]
          @zone = options[:zone]
        else
          @zone = ZONE
        end
      
        @uri = options["dnsName"] || ""
        @type = options[:type] || options["instanceType"]
        @image_id = options[:image_id] || options["imageId"]
        @key_name = options[:key_name] || options["keyName"]

        @create_time = options["launchTime"] || nil
      
        if options["instanceState"] and options["instanceState"]["name"]
          @status = options["instanceState"]["name"]
        else
          @status = "unknown"
        end

        # @security_group = options[:security_group] || nil
        # if options["groupSet"] and options["groupSet"]["item"] and options["groupSet"]["item"][0]
        #   @security_group = options["groupSet"]["item"][0]["groupId"]
        # end
        
      end
      
    
      def create
        @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        result = @ec2.run_instances(:image_id => self.image_id, :key_name => self.key_name, 
          :max_count => 1,
          :availability_zone => self.zone) unless self.create_time
        set_attributes(result.instancesSet.item[0]) if result.instancesSet.item[0]
        self
      end
    
      def destroy
        @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        @ec2.terminate_instances(:instance_id => self.name)
      end
    
      def save
        self.create
      end
    
      def ssh(commands, dna=nil, key_pair_file=nil)
        raise ArgumentError.new("Key Pair File is required") if key_pair_file.nil?
        begin
          Net::SSH.start(self.uri, "ubuntu", :keys => key_pair_file) do |ssh|
            if dna
              ssh.exec!("echo \"#{dna.to_json.gsub('"','\"')}\" > ~/dna.json")
            end
            commands.each do |cmd|
              puts ssh.exec!(cmd)
            end
          end
        rescue
        end
      end
    
      def self.find_or_create_security_group(name, description)
        @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        begin
          @security_groups = @ec2.describe_security_groups(:group_name => name)
        rescue
          @security_groups = @ec2.create_security_group(:group_name => name, :group_description => description)
        end
        @security_groups
      end

      def self.destroy_security_group(name)
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

      # def self.find(url)
      #   @ec2 = AWS::EC2::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      #   self.new(@ec2.describe_instances(:instance_id => instance).reservationSet.item[0].instancesSet.item[0])
      # end
    
      def self.find_or_create(options)
        if options[:name]
          self.find(options[:name]) 
        else
          self.new(options).create
        end
      end
    end
  end
end
