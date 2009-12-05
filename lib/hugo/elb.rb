module Hugo
  class Elb
    ACCESS_KEY = ENV['AMAZON_ACCESS_KEY_ID'] 
    SECRET_KEY = ENV['AMAZON_SECRET_ACCESS_KEY'] 
    ZONES = ["us-east-1c"]
    LISTENERS = [{"InstancePort"=>"8080", "Protocol"=>"HTTP", "LoadBalancerPort"=>"80"}, 
      {"InstancePort"=>"8443", "Protocol"=>"TCP", "LoadBalancerPort"=>"443"}]
    
    def initialize(options = {} )
      self.name = options[:name] || options["LoadBalancerName"]
      self.uri = options["DNSName"] || nil
      if options["Instances"] and options["Instances"]["member"]
        self.instances = options["Instances"]["member"].map { |i| i.InstanceId }
      end
      if options["AvailabilityZones"] and options["AvailabilityZones"]["member"]
        self.zones = options["AvailabilityZones"]["member"]
      else
        self.zones = options["zones"] || ZONES
      end
      if options["Listeners"] and options["Listeners"]["member"]
        self.listeners = options["Listeners"]["member"]
      else
        self.listeners = options["listeners"] || LISTENERS
      end
      if options["CreatedTime"]
        self.create_time = options["CreatedTime"]
      end
    end
    
    def create
      @elb = AWS::ELB::Base.new(:access_key_id => Hugo::Elb::ACCESS_KEY, :secret_access_key => Hugo::Elb::SECRET_KEY)
      @elb.create_load_balancer(
        :load_balancer_name => self.name,
        :listeners => self.listeners,
        :availability_zones => self.zones
      ) unless self.create_time
      true
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
        :load_balancer_name => self.name)
      self.instances << instance
      self
    end
    
    def remove(instance)
      @elb = AWS::ELB::Base.new(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY)
      @elb.deregister_instances_from_load_balancer(
        :instances => [instance],
        :load_balancer_name => self.name)
      self.instances = self.instances - [instance]
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
    
    def listeners
      @listeners
    end
    
    def listeners=(listeners)
      @listeners = listeners
    end
    
    def instances
      @instances
    end
    
    def instances=(instances)
      @instances = instances
    end
    
    
    def zones
      @zones
    end
    
    def zones=(zones)
      @zones = zones
    end
    
    def create_time
      @create_time
    end
    
    def create_time=(create_time)
      @create_time = create_time
    end

  end
end