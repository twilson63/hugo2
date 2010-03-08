require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.add_dependency('amazon-ec2')
    gemspec.add_dependency('net-ssh')
    gemspec.add_dependency('json')
    
    gemspec.name = "hugo"
    gemspec.summary = "Deploy Your Rack Apps to EC2 Cloud"
    gemspec.description = "Deploy your apps to the EC2 cloud."
    gemspec.email = "tom@jackhq.com"
    gemspec.homepage = "http://github.com/twilson63/hugo2"
    gemspec.authors = ["Tom Wilson", "Barrett Little"]

    gemspec.add_dependency('amazon-ec2', '>= 0.7.5')
    gemspec.add_dependency('json', '>= 1.2.0')
    gemspec.add_dependency('net-ssh', '>= 2.0.16')

    gemspec.files = FileList['spec/*.rb'] + FileList['lib/**/*.rb'] + ['README.rdoc', 'LICENSE', 'VERSION.yml', 'Rakefile']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end