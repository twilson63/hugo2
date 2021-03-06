module Hugo; end

# Lauch Database Servers 
class Hugo::Database
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
  DEFAULT_SERVER = "DEFAULT"
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  
  attr_accessor :rds

  # initialize defaults
  def initialize
    size DEFAULT_SIZE
    zone DEFAULT_ZONE
    server DEFAULT_SERVER
    db_security_group "default"
  end

  # deploy using AWS RDS
  def deploy
    raise ArgumentError, "database.name Required" unless name
    raise ArgumentError, "database.server Required" unless server
    raise ArgumentError, "database.user Required" unless user
    raise ArgumentError, "database.password Required" unless password
    raise ArgumentError, "database.aws_access_key_id Required" unless aws_access_key_id
    raise ArgumentError, "database.aws_secret_access_key Required" unless aws_secret_access_key
    
    
    @rds = Hugo::Aws::Rds.find_or_create( :name => name,
                              :server => server,
                              :user => user,
                              :password => password,
                              :size => size,
                              :zone => zone,
                              :db_security_group => db_security_group,
                              :aws_access_key_id => aws_access_key_id,
                              :aws_secret_access_key => aws_secret_access_key
                              
                               )
    self
  end
  
  # clear attributes of database object
  def clear
    @user = nil
    @password = nil
    @server = nil
    @aws_access_key_id = nil
    @aws_secret_access_key = nil
    
  end
  
  def help
    
    x = <<HELP
Welcome to Hugo::Database
-------------------------

Required Methods:
-------------------------
name - Name of Database
server - Name of Server
user - A Valid User of RDS Server
password - A Valid Password of RDS Server    

Optional Methods:
-------------------------
size - Storage Size of you db server
zone - Zone of the AWS:RDS

HELP
    puts x
    x
  end
  
  def info
    { 
      :uri => @rds.uri, 
      :name => @rds.db,
      :user => @rds.user, 
      :password => @rds.password 
      } 
    
  end
  
  
  def name(arg=nil)
    set_or_return(:name, arg, :kind_of => [String])     
  end

  def server(arg=nil)
    set_or_return(:server, arg, :kind_of => [String])     
  end

  def user(arg=nil)
    set_or_return(:user, arg, :kind_of => [String])     
  end

  def password(arg=nil)
    set_or_return(:password, arg, :kind_of => [String])     
  end

  def size(arg=nil)
    set_or_return(:size, arg, :kind_of => [Integer])     
  end

  def zone(arg=nil)
    set_or_return(:zone, arg, :kind_of => [String])     
  end

  def db_security_group(arg=nil)
    set_or_return(:db_security_group, arg, :kind_of => [String])     
  end

  # Aws Access Key for EC2 Deployment
  def aws_access_key_id(arg=nil)
    set_or_return(:aws_access_key_id, arg, :kind_of => [String]) 
  end

  # Aws Access Secret Key for EC2 Deployment
  def aws_secret_access_key(arg=nil)
    set_or_return(:aws_secret_access_key, arg, :kind_of => [String]) 
  end
    
end
