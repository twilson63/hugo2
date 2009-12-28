module Hugo; end
  
class Hugo::AppServer
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_IMAGE_ID = 'ami-1515f67c'
  DEFAULT_KEY_NAME = 'ec2-keypair'
  
  attr_accessor :name, :uri, :type, :zone, :image_id, :key_name

  def initialize
    self.zone = DEFAULT_ZONE
    self.image_id = DEFAULT_IMAGE_ID
    self.key_name = DEFAULT_KEY_NAME
  end
  
  def deploy
    Hugo::Ec2.find_or_create(:name => name,
                             :uri => uri,
                             :type => type, 
                             :zone => zone, 
                             :image_id => image_id,
                             :key_name => key_name
                            )
  end
end