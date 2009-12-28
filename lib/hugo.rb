# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require 'singleton'
require 'hugo/base'
require 'hugo/app_server'
require 'hugo/balancer'
require 'hugo/database'
require 'hugo/rds'
require 'hugo/elb'
require 'hugo/ec2'

module Hugo; end

class Hugo::Suite
  include Singleton

  def initialize
  end
  
  def cloud(name="DEFAULT", &block)
    cloud = Hugo::Cloud.instance
    cloud.name = name
    cloud.instance_eval(&block)
  end
end

class Hugo::Cloud
  include Singleton
  attr_accessor :name
  
  def database(name=self.name, &block)
    database = Hugo::Database.instance
    database.name = name
    database.instance_eval(&block)
    database.deploy
    database
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name = self.name
    balancer.instance_eval(&block)
    balancer.deploy
    balancer
  end

  def app_server(name=self.name, &block)
    app_server = Hugo::AppServer.instance
    app_server.name = name
    app_server.instance_eval(&block)
    app_server.deploy
    app_server
  end
  
end

def Hugo(&block) 
  Hugo::Suite.instance.instance_eval(&block)
end

# Hugo do
#   cloud "my_cloud" do 
#     database do end
#     
#     b = balancer do end
# 
#     2.times do |i|
#       a = app_server("server_" + i.to_s) do 
#         
#       end
#       b.attach(a)
#     end
# 
#   end
# end