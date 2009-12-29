module Hugo; end

class Hugo::Database
  include Singleton
  DEFAULT_SERVER = "DEFAULT"
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  
  attr_accessor :name, :server, :user, :password, :size, :zone, :db_security_group

  def initialize
    self.size = DEFAULT_SIZE
    self.zone = DEFAULT_ZONE
    self.server = DEFAULT_SERVER
    self.db_security_group = "default"
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
end
