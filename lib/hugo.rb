# begin
#   # Require the preresolved locked set of gems.
#   require File.expand_path('../.bundle/environment', __FILE__)
# rescue LoadError
#   # Fallback on doing the resolve at runtime.
#   require "rubygems"
#   require "bundler"
#   Bundler.setup
# end

require 'AWS'
require 'net/ssh'
require 'json'
require 'singleton'
require File.dirname(__FILE__) + '/hugo/mixin/params_validate'
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
    cloud.name name
    cloud.instance_eval(&block) if block_given?   
  end
end


def Hugo(&block) 
  Hugo::Suite.instance.instance_eval(&block)
end

