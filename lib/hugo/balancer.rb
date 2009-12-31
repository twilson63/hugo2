module Hugo; end
  
class Hugo::Balancer
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_PORT = '8080'
  DEFAULT_WEB = '80'
  DEFAULT_TYPE = 'http'
  DEFAULT_SSL_PORT = '8443'
  DEFAULT_SSL_WEB = '443'
  
  def initialize
    zone DEFAULT_ZONE
    port DEFAULT_PORT
    web DEFAULT_WEB
    ssl_port DEFAULT_SSL_PORT
    ssl_web DEFAULT_SSL_WEB
    type DEFAULT_TYPE
  end
  
  def deploy
    Hugo::Aws::Elb.find_or_create(:name => self.name,
                            :zones => self.zone,
                            :listeners => [{ :instance_port => self.port, :protocol =>"HTTP", :load_balancer_port => self.web}, 
                              { :instance_port => self.ssl_port, :protocol =>"TCP", :load_balancer_port => self.ssl_web}]
    )
  end
  
  def name(arg=nil)
    set_or_return(:name, arg, :kind_of => [String])     
  end
  
  def zone(arg=nil)
    set_or_return(:zone, arg, :kind_of => [String])     
  end

  def port(arg=nil)
    set_or_return(:port, arg, :kind_of => [String])     
  end

  def web(arg=nil)
    set_or_return(:web, arg, :kind_of => [String])     
  end

  def type(arg=nil)
    set_or_return(:type, arg, :kind_of => [String])     
  end

  def ssl_port(arg=nil)
    set_or_return(:ssl_port, arg, :kind_of => [String])     
  end
  
  def ssl_web(arg=nil)
    set_or_return(:ssl_web, arg, :kind_of => [String])     
  end
  
end