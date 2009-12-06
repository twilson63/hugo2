# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require 'hugo/rds'
require 'hugo/elb'
require 'hugo/ec2'