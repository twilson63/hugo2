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
    Hugo::Aws::Elb.find_or_create(:name => name,
                            :zones => zone,
                            :listeners => [{ :instance_port => port, :protocol =>"HTTP", :load_balancer_port => web}, 
                              { :instance_port => ssl_port, :protocol =>"TCP", :load_balancer_port => ssl_web}]
    )
  end
  
  def help
    x = <<HELP

Hugo balancer 
-----------------

optional attributes
-----------------
zone - zone
port - app server port 
web - balancer port
ssl_port - ssl app server port
ssl_web - ssl balancer port
type - port type


defaults
-----------------
DEFAULT_ZONE = 'us-east-1c'
DEFAULT_PORT = '8080'
DEFAULT_WEB = '80'
DEFAULT_TYPE = 'http'
DEFAULT_SSL_PORT = '8443'
DEFAULT_SSL_WEB = '443'



HELP
    puts x
    x
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