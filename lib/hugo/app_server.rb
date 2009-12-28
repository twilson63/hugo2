module Hugo; end
  
class Hugo::AppServer
  include Singleton
  attr_accessor :name

  def initialize
  end
end