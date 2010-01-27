require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.add_dependency('amazon-ec2')
    gemspec.add_dependency('net-ssh')
    gemspec.add_dependency('json')
    
    gemspec.name = "hugo"
    gemspec.summary = "Deploy Your Rack Apps to Cloud"
    gemspec.description = "A easy to understand DSL that makes it dirt simple to deploy to the cloud."
    gemspec.email = "tom@jackhq.com"
    gemspec.homepage = "http://github.com/twilson63/hugo"
    gemspec.authors = ["Tom Wilson", "Barrett Little"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end