module Hugo; end
  
class Hugo::Balancer
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_PORT = '8080'
  DEFAULT_WEB = '80'
  DEFAULT_TYPE = 'http'
  DEFAULT_SSL_PORT = '8443'
  DEFAULT_SSL_WEB = '443'
  
  attr_accessor :name, :zone, :port, :web, :type, :ssl_port, :ssl_web

  def initialize
    self.zone = DEFAULT_ZONE
    self.port = DEFAULT_PORT
    self.web = DEFAULT_WEB
    self.ssl_port = DEFAULT_SSL_PORT
    self.ssl_web = DEFAULT_SSL_WEB

    self.type = DEFAULT_TYPE
  end
  
  def deploy
    Hugo::Elb.find_or_create(:name => self.name,
                            :zones => self.zone,
                            :listeners => [{"InstancePort"=> self.port, "Protocol"=>"HTTP", "LoadBalancerPort"=> self.web}, 
                              {"InstancePort"=> self.ssl_port, "Protocol"=>"TCP", "LoadBalancerPort"=> self.ssl_web}]
    )
  end
  
end