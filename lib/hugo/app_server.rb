module Hugo; end
  
class Hugo::AppServer
  include Singleton
  attr_accessor :name

  def initialize
  end
  
  def deploy
    Hugo::Ec2.find_or_create()
  end
  
end