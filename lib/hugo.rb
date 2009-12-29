# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require 'singleton'
require 'hugo/cloud'
require 'hugo/balancer'
require 'hugo/database'
require 'hugo/aws/rds'
require 'hugo/aws/elb'
require 'hugo/aws/ec2'

module Hugo; end

class Hugo::Suite
  include Singleton

  def initialize
  end
  
  def cloud(name="DEFAULT", &block)
    cloud = Hugo::Cloud.instance
    cloud.instance_eval(&block) if block_given?   
    cloud.name = name
    cloud.deploy
  end
end


def Hugo(&block) 
  Hugo::Suite.instance.instance_eval(&block)
end

