module Hugo; end
  
class Hugo::Cloud
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
                      
  def initialize

  end

  def database(db_name, &block)    
    database = Hugo::Database.instance
    
    database.db_security_group name
    database.server name
    database.name db_name
    
    database.instance_eval(&block) if block_given? 
    db database.deploy 
  
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name name
    balancer.instance_eval(&block) if block_given? 
    lb balancer.deploy 
  end
  
  def app(name, &block)
    app_info = Hugo::App.instance
    app_info.name name
    app_info.lb lb
    app_info.db db
    #app_info.cloud_name name
    app_info.instance_eval(&block) if block_given? 
    cloud_app app_info
    
  end
  
  def deploy
    if cloud_app
      cloud_app.setup
      cloud_app.deploy
    end
    
  end
  
  def delete
    [cloud_app, lb].each do |s|
      s.destroy if s
    end
    db.rds.destroy
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
    else
      ec2 = Hugo::Aws::Ec2.find(cloud_app.instance)
      puts <<REPORT

Since you are not running a balancer
you need to remember to add #{ec2.name} as the instance method in your app
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
    set_or_return(:db, arg, :kind_of => [Hugo::Database])
  end
  
  def lb(arg=nil)
    set_or_return(:lb, arg, :kind_of => [Hugo::Aws::Elb])    
  end

  def cloud_app(arg=nil)
    set_or_return(:cloud_app, arg, :kind_of => [Hugo::App])    
  end
  
  
  


end
