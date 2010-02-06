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

    gemspec.add_dependency('amazon-ec2', '>= 0.7.5')
    gemspec.add_dependency('json', '>= 1.2.0')
    gemspec.add_dependency('net-ssh', '>= 2.0.16')
    gemspec.add_dependency('builder', '>= 0')
    gemspec.add_dependency('i18n', '>= 0')
    gemspec.add_dependency('activesupport', '>= 2.3.5')
    gemspec.add_dependency('activeresource', '>= 2.3.5')
    gemspec.add_dependency('zerigo_dns', '>= 1.0.0')

    gemspec.files = FileList['spec/*.rb'] + FileList['lib/**/*.rb'] + ['README.rdoc', 'LICENSE', 'VERSION.yml', 'Rakefile']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end