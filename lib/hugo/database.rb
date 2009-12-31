module Hugo; end

class Hugo::Database
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
  DEFAULT_SERVER = "DEFAULT"
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  

  def initialize
    self.size DEFAULT_SIZE
    self.zone DEFAULT_ZONE
    self.server DEFAULT_SERVER
    self.db_security_group "default"
  end
  
  def deploy
    Hugo::Aws::Rds.find_or_create( :name => self.name,
                              :server => self.server,
                              :user => self.user,
                              :password => self.password,
                              :size => self.size,
                              :zone => self.zone,
                              :db_security_group => self.db_security_group
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
