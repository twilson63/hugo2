module Hugo; end
  
class Hugo::Cloud
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
                      
  def initialize

  end

  def database(name, &block)
    database = Hugo::Database.instance
    
    database.db_security_group self.name
    database.server self.name
    database.name name
    
    database.instance_eval(&block) if block_given? 
    
    self.db database.deploy
    self.db
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name self.name
    balancer.instance_eval(&block) if block_given? 
    self.lb balancer.deploy
    self.lb
  end
  
  def app(name, &block)
    app_info = Hugo::App.instance
    app_info.name name
    app_info.lb lb
    app_info.db db
    app_info.cloud_name name
    app_info.instance_eval(&block) if block_given?    
  end
  
    
  def print
    if db
      puts <<REPORT
------------------------    
DATABASE: #{db.db}
  User: #{db.user}
  Password: #{db.password}
  Uri: #{db.uri}
REPORT
    end
    
    if lb
      puts <<REPORT
-----------------------  
Balancer: #{lb.name}
  Uri: #{lb.uri}
  Servers: #{lb.instances.length}
REPORT
    end
  
    lb.instances.each do |i|
      ec2 = Hugo::Aws::Ec2.find(i)
      puts <<REPORT
-----------------------      
Id: #{ec2.name}
Uri: #{ec2.uri}
Type: #{ec2.type}
Zone: #{ec2.zone}

REPORT
    end
  end

  def name(arg=nil)
    set_or_return(:name, arg, :kind_of => [String])
  end
  
  def db(arg=nil)
    set_or_return(:db, arg, :kind_of => [Hugo::Aws::Rds])
  end
  
  def lb(arg=nil)
    set_or_return(:lb, arg, :kind_of => [Hugo::Aws::Elb])    
  end
  
  
  


end