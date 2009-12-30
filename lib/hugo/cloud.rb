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
    puts "Database Deployed!"
    self.db
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name = self.name
    balancer.instance_eval(&block) if block_given? 
    self.port = balancer.port
    self.ssl = balancer.ssl_port
    self.lb = balancer.deploy
    puts "Balancer Deployed!"
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
  
  
  def deploy
    # Find or Create Security Group
    # Hugo::Aws::Ec2.find_or_create_security_group(self.security_group, self.security_group)
    # Need to compare balancer instances to instances
    if self.instances > lb.instances.length
      build_ec2(self.instances - lb.instances.length)
    elsif self.instances < lb.instances.length
      delete_ec2(lb.instances.length - self.instances)
    end
    puts "EC2 Created"
    deploy_ec2      
  end
  
  def print
    puts "---- DB Info ----"
    puts self.db.inspect
    puts "---- ELB Info ----"
    puts self.lb.inspect
    puts "---- App Info ----"
    puts self.app_info.inspect
  end
  
  


end