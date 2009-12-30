module Hugo; end
  
class Hugo::Cloud
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_IMAGE_ID = 'ami-1515f67c'
  DEFAULT_KEY_NAME = 'ec2-keypair'
  DEFAULT_COOKBOOK = 'git://github.com/twilson63/hugo-cookbooks.git'
  
  attr_accessor :name, :uri, :type, :zone, :image_id, 
                :db, :lb, 
                :port, :ssl, :application, :cookbook,
                :github_url, :publickey, :privatekey,
                :gem_list, :package_list, :run_list, :app_info,
                :security_group
                  
  def initialize
    self.zone = DEFAULT_ZONE
    self.image_id = DEFAULT_IMAGE_ID
    #self.key_name = DEFAULT_KEY_NAME
    #self.instances = 1
    self.cookbook = DEFAULT_COOKBOOK
  end

  def database(name, &block)
    database = Hugo::Database.instance
    
    database.db_security_group = self.name
    database.server = self.name
    database.name = name
    
    database.instance_eval(&block) if block_given? 
    
    self.db = database.deploy
    self.db
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name = self.name
    balancer.instance_eval(&block) if block_given? 
    self.port = balancer.port
    self.ssl = balancer.ssl_port
    self.lb = balancer.deploy
    self.lb
  end
  
  def app(name, &block)
    self.app_info = Hugo::App.instance
    self.app_info.name = name
    self.app_info.lb = self.lb
    self.app_info.db = self.db
    self.app_info.cloud_name = self.name
    self.app_info.instance_eval(&block) if block_given?    
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
  
  


end