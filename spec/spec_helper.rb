require File.expand_path(File.dirname(__FILE__) + "/../lib/hugo")

Bundler.require_env(:test)    # get rspec and webrat in here


# require 'rubygems'
# require 'sinatra'
#require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

