module Hugo
  module Aws
    class Elb
    
      ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
      SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
      ZONES = ["us-east-1c"]
      LISTENERS = [{"InstancePort"=>"8080", "Protocol"=>"HTTP", "LoadBalancerPort"=>"80"}, 
        {"InstancePort"=>"8443", "Protocol"=>"TCP", "LoadBalancerPort"=>"443"}]
    
      attr_accessor :name, :uri, :listeners, :instances, :zones, :create_time, :aws_access_key_id, :aws_secret_access_key
    
      def initialize(options = {} )
        @name = options[:name] || options["LoadBalancerName"]
    
        @uri = options["DNSName"] if options["DNSName"]
            
        if options["Instances"] and options["Instances"]["member"]
          @instances = options["Instances"]["member"].map { |i| i.InstanceId }
        else
          @instances = []
        end
        if options["AvailabilityZones"] and options["AvailabilityZones"]["member"]
          @zones = options["AvailabilityZones"]["member"]
        else
          @zones = options[:zones] || ZONES
        end
        if options["Listeners"] and options["Listeners"]["member"]
          @listeners = options["Listeners"]["member"]
        else
          @listeners = options[:listeners] || LISTENERS
        end
        if options["CreatedTime"]
          @create_time = options["CreatedTime"]
        end

        @aws_access_key_id = options[:aws_access_key_id] || ACCESS_KEY
        @aws_secret_access_key = options[:aws_secret_access_key] || SECRET_KEY
        
      end
    
      def create
        elb.create_load_balancer(
          :load_balancer_name => self.name,
          :listeners => self.listeners,
          :availability_zones => self.zones
        ) unless self.create_time
        self
      end
    
      def destroy
        elb.delete_load_balancer(:load_balancer_name => self.name)
      end
    
      def save
        self.create
      end
    
      def add(instance)
        elb.register_instances_with_load_balancer(
          :instances => [instance],
          :load_balancer_name => @name)
        @instances << instance
        self
      end
    
      def remove(instance)
        
        elb.deregister_instances_from_load_balancer(
          :instances => [instance],
          :load_balancer_name => @name)
        @instances = @instances - [instance]
        self
      end
    
      def self.all(aws_access_key_id, aws_secret_access_key)
        @elb = AWS::ELB::Base.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
        instances = @elb.describe_load_balancers().DescribeLoadBalancersResult.LoadBalancerDescriptions.member      
        instances.map { |i| self.new(i) }
      end
    
      def self.find(balancer, aws_access_key_id, aws_secret_access_key)
        @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
        
        result = nil
    
        @elb.describe_load_balancers().DescribeLoadBalancersResult.LoadBalancerDescriptions.member.each do |m|
          result = self.new(m) if m.LoadBalancerName == balancer
        end
        
        result
      rescue
        nil
      end
    
      def self.find_or_create(options)
        self.find(options[:name], options[:aws_access_key_id], options[:aws_secret_access_key]) || self.new(options).create
      end
      
    private
      def elb
        AWS::ELB::Base.new(:access_key_id => self.aws_access_key_id, :secret_access_key => self.aws_secret_access_key)
      end
      
    end
  end
end