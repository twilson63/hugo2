module Hugo; end
  
class Hugo::Balancer
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_PORT = '8080'
  DEFAULT_WEB = '80'
  DEFAULT_TYPE = 'http'
  
  attr_accessor :name, :zone, :port, :web, :type

  def initialize
    self.zone = DEFAULT_ZONE
    self.port = DEFAULT_PORT
    self.web = DEFAULT_WEB
    self.type = DEFAULT_TYPE
  end
end