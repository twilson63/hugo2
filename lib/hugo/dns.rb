module Hugo; end

class Hugo::Dns
  include Singleton
  include Hugo::Mixin::ParamsValidate

  attr_accessor :host

  def deploy

    # Initialize Resouce
    Zerigo::DNS::Base.user = user
    Zerigo::DNS::Base.password = token

    # find or create domain
    zone = Zerigo::DNS::Zone.find_or_create(domain)

    # find or create host
    host = Zerigo::DNS::Host.update_or_create(
          :zone     => zone.id, 
          :host     => hostname, 
          :type     => type,
          :ttl      => ttl,
          :data     => data  
      )
  end
  
  def user(arg=nil)
    set_or_return(:user, arg, :kind_of => [String]) 
  end

  def token(arg=nil)
    set_or_return(:token, arg, :kind_of => [String]) 
  end

  def hostname(arg=nil)
    set_or_return(:hostname, arg, :kind_of => [String]) 
  end

  def domain(arg=nil)
    set_or_return(:domain, arg, :kind_of => [String]) 
  end

  def type(arg=nil)
    set_or_return(:type, arg, :kind_of => [String]) 
  end

  def ttl(arg=nil)
    set_or_return(:ttl, arg, :kind_of => [Integer]) 
  end

  def data(arg=nil)
    set_or_return(:data, arg, :kind_of => [String]) 
  end
  
  
end