# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require 'hugo/rds'
require 'hugo/elb'
require 'hugo/ec2'

module Hugo
  
  class << self
    def build(infrastructure, application, instances = 1)
      app_config = YAML.load_file("config/#{application}.yml")
      @rds = Rds.new(:server => infrastructure, :db => application, :user => app_config["db"]["user"], :pwd => app_config["db"]["password"])
      @rds.save
      @elb = Elb.new(:name => infrastructure)
      @elb.save
      
      instances.times do 
        @ec2 = Ec2.new()
        @ec2.save
        @elb.add(@ec2.name)
      end
      
      setup(infrastructure, application)
      
      deploy(infrastructure, application)
      
    end
    
    def drop(infrastructure)
      Rds.find(infrastructure).destroy
      @elb = Elb.find(infrastructure)
      @elb.instances.each do |i|
        Ec2.find(i).destroy
      end
      @elb.destroy
    end
    
    def setup(infrastructure, application)
      @elb = Elb.find(infrastructure)
      @elb.instances.each do |i|
        Ec2.find(i).ssh()
      end
      
    end
    
    def deploy(infrastructure, application)
      @elb = Elb.find(infrastructure)
      @elb.instances.each do |i|
        Ec2.find(i).ssh()
      end
    end
    
  end
  
end
