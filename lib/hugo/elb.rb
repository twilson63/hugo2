module Hugo
  class Elb
    
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
    ZONES = ["us-east-1c"]
    LISTENERS = [{"InstancePort"=>"8080", "Protocol"=>"HTTP", "LoadBalancerPort"=>"80"}, 
      {"InstancePort"=>"8443", "Protocol"=>"TCP", "LoadBalancerPort"=>"443"}]
    
    attr_accessor :name, :uri, :listeners, :instances, :zones, :create_time
    
    def initialize(options = {} )
      @name = options[:name] || options["LoadBalancerName"]
      @uri = options["DNSName"] || nil
      if options["Instances"] and options["Instances"]["member"]
        @instances = options["Instances"]["member"].map { |i| i.InstanceId }
      end
      if options["AvailabilityZones"] and options["AvailabilityZones"]["member"]
        @zones = options["AvailabilityZones"]["member"]
      else
        @zones = options["zones"] || ZONES
      end
      if options["Listeners"] and options["Listeners"]["member"]
        @listeners = options["Listeners"]["member"]
      else
        @listeners = options["listeners"] || LISTENERS
      end
      if options["CreatedTime"]
        @create_time = options["CreatedTime"]
      end
    end
    
    def create
      @elb = AWS::ELB::Base.new(:access_key_id => Hugo::Elb::ACCESS_KEY, :secret_access_key => Hugo::Elb::SECRET_KEY)
      @elb.create_load_balancer(
        :load_balancer_name => self.name,
        :listeners => self.listeners,
        :availability_zones => self.zones
      ) unless self.create_time
      self
    end
    
    def destroy
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @elb.delete_load_balancer(:load_balancer_name => self.name)
    end
    
    def save
      self.create
    end
    
    def add(instance)
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @elb.register_instances_with_load_balancer(
        :instances => [instance],
        :load_balancer_name => @name)
      @instances << instance
      self
    end
    
    def remove(instance)
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @elb.deregister_instances_from_load_balancer(
        :instances => [instance],
        :load_balancer_name => @name)
      @instances = @instances - [instance]
      self
    end
    
    def self.all
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      instances = @elb.describe_load_balancers().DescribeLoadBalancersResult.LoadBalancerDescriptions.member      
      instances.map { |i| self.new(i) }
    end
    
    def self.find(balancer)
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      results = @elb.describe_load_balancers(:load_balancer_names => balancer).DescribeLoadBalancersResult.LoadBalancerDescriptions.member
      self.new(results[0])
    end
    
    def self.find_or_create(options)
      self.find(options[:name]) || self.new(options).create
    end
  end
end