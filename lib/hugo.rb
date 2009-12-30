# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require 'json'
require 'singleton'
require File.dirname(__FILE__) + '/hugo/cloud'
require File.dirname(__FILE__) + '/hugo/balancer'
require File.dirname(__FILE__) + '/hugo/database'
require File.dirname(__FILE__) + '/hugo/app'
require File.dirname(__FILE__) + '/hugo/aws/rds'
require File.dirname(__FILE__) + '/hugo/aws/elb'
require File.dirname(__FILE__) + '/hugo/aws/ec2'

module Hugo; end

class Hugo::Suite
  include Singleton

  def initialize
  end
  
  def cloud(name="DEFAULT", &block)
    cloud = Hugo::Cloud.instance
    cloud.security_group = name
    cloud.name = name
    cloud.instance_eval(&block) if block_given?   
    #cloud.deploy
  end
end


def Hugo(&block) 
  Hugo::Suite.instance.instance_eval(&block)
end

