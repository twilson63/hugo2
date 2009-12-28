module Hugo; end

class Hugo::Database
  include Singleton
  DEFAULT_SERVER = "DEFAULT"
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  
  attr_accessor :name, :server, :user, :password, :size, :zone

  def initialize
    self.size = DEFAULT_SIZE
    self.zone = DEFAULT_ZONE
    self.server = DEFAULT_SERVER
  end

  def deploy
    Hugo::Rds.find_or_create( :name => self.name,
                              :server => self.server,
                              :user => self.user,
                              :password => self.password,
                              :size => self.size,
                              :zone => self.zone
                               )
    
  end
end
