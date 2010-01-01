module Hugo; end

class Hugo::Database
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
  DEFAULT_SERVER = "DEFAULT"
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  

  def initialize
    size DEFAULT_SIZE
    zone DEFAULT_ZONE
    server DEFAULT_SERVER
    db_security_group "default"
  end
  
  def deploy
    Hugo::Aws::Rds.find_or_create( :name => name,
                              :server => server,
                              :user => user,
                              :password => password,
                              :size => size,
                              :zone => zone,
                              :db_security_group => db_security_group
                               )
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
    
end
