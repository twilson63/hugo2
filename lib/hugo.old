# This makes sure the bundled gems are in our $LOAD_PATH
require File.expand_path(File.join(File.dirname(__FILE__) + "/..", 'vendor', 'gems', 'environment'))

# This actually requires the bundled gems
Bundler.require_env

require 'AWS'
require 'net/ssh'
require File.dirname(__FILE__) + '/hugo/rds'
require File.dirname(__FILE__) + '/hugo/elb'
require File.dirname(__FILE__) + '/hugo/ec2'

module Hugo
  
  class << self
    def build(infrastructure, application, instances = 1)
      app_config = YAML.load_file("config/#{application}.yml")
      @rds = Rds.new(:server => infrastructure, :db => application, 
        :user => app_config['database']['master_username'], 
        :pwd => app_config['database']['master_user_password']
      )
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
      hugo_config = YAML.load_file("config/hugo.yml")

      commands = []
      commands << 'sudo apt-get update -y'
      commands << 'sudo apt-get install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb build-essential git-core xfsprogs -y'
      commands << 'wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz && tar zxf rubygems-1.3.5.tgz'
      commands << 'cd rubygems-1.3.5 && sudo ruby setup.rb && sudo ln -sfv /usr/bin/gem1.8 /usr/bin/gem'
      commands << 'sudo gem update --system'
      commands << 'sudo gem install gemcutter --no-ri --no-rdoc'
      commands << 'sudo gem tumble'
      commands << 'sudo gem install chef ohai --no-ri --no-rdoc'
      commands << 'sudo gem source -a http://gems.github.com'
      commands << 'sudo gem install chef-deploy --no-ri --no-rdoc'
      commands << 'sudo gem install git --no-ri --no-rdoc'
      commands << "git clone #{hugo_config['git']} ~/hugo-repos"
      # Setup base role
      dna = { :run_list => ["role[web-base]"],
        :package_list => hugo_config['package_list'],
        :gem_list => hugo_config['gem_list'],
        :git => hugo_config['git'],
        :github => hugo_config['github'],
        :access_key => Ec2::ACCESS_KEY,
        :secret_key => Ec2::SECRET_KEY,
        :apache => hugo_config['apache']

      }

      commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'

      @elb = Elb.find(infrastructure)
      @elb.instances.each do |i|
        Ec2.find(i).ssh(commands, dna)
      end
      
    end
    
    def deploy(infrastructure, application)
      hugo_config = YAML.load_file("config/hugo.yml")
      app_config = YAML.load_file("config/#{application}.yml")
      
      commands = []
      #commands << "git clone #{@@hugo_config['git']} ~/hugo-repos"
      commands << "cd hugo-repos && git pull"
      commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'

      dna = { :run_list => app_config['run_list'],
        :package_list => app_config['package_list'] || {},
        :gem_list => app_config['gem_list'] || {},
        :application => application, 
        :customer => infrastructure,
        :database => { 
          :uri => Rds.find(infrastructure).uri, 
          :user => app_config['database']['master_username'], 
          :password => app_config['database']['master_user_password'] }, 
        :web => { :port => "8080", :ssl => "8443" }, 
        :git => hugo_config['git'],
        :github => hugo_config['github'],
        :access_key => Ec2::ACCESS_KEY,
        :secret_key => Ec2::SECRET_KEY,
        :app => app_config['app'] || nil
      }
      
      @elb = Elb.find(infrastructure)
      @elb.instances.each do |i|
        Ec2.find(i).ssh(commands, dna)
      end
    end
  
    def add(infrastructure, application)
      @elb = Elb.find(infrastructure)
      
    end
    
  end
  
end
