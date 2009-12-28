module Hugo; end

class Hugo::Database
  include Singleton
  DEFAULT_SIZE = 5
  DEFAULT_ZONE = 'us-east-1c'
  
  attr_accessor :name, :user, :password, :size, :zone

  def initialize
    self.size = DEFAULT_SIZE
    self.zone = DEFAULT_ZONE
  end
end