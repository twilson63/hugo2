module Hugo; end
  
class Hugo::AppServer
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_IMAGE_ID = 'ami-1515f67c'
  DEFAULT_KEY_NAME = 'ec2-keypair'
  
  attr_accessor :name, :uri, :type, :zone, :image_id, 
                :key_name, :db, :lb, :instances,
                :port, :ssl, :application, :cloud
                  
  def database(name, &block)
    database = Hugo::Database.instance
    database.instance_eval(&block)
    database.name = name

    self.db = database.deploy
    self.db
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name = self.name
    balancer.instance_eval(&block)
    self.port = balancer.port
    self.ssl = balancer.ssl_port
    self.lb = balancer.deploy
    self.lb
  end

  def initialize
    self.zone = DEFAULT_ZONE
    self.image_id = DEFAULT_IMAGE_ID
    self.key_name = DEFAULT_KEY_NAME
    self.instances = 1
    
  end
    
  
  def deploy
    # Need to compare balancer instances to instances
    if self.instances > lb.instances.length
      build_ec2(self.instances - lb.instances.length)
    elsif self.instances < lb.instances.length
      delete_ec2(lb.instances.length - self.instances)
    end
    deploy_ec2      
  end
  
private

  def build_ec2(i=1)
    i.times do
      instance_id = create_ec2
      setup_ec2(instance_id)
      lb.add(instance_id)
    end
  end
  
  def create_ec2
    ec2 = Hugo::Ec2.create(:type => self.type, 
                    :zone => self.zone, 
                    :image_id => self.image_id,
                    :key_name => self.key_name)
    new_ec2 = nil
    loop do
      new_ec2 = Hugo::Ec2.find(ec2.name)
      if new_ec2.status == "running"
        break
      end
    end
    
    new_ec2.name
  end

  def setup_ec2
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

    Ec2.find(instance_id).ssh(commands, dna)
  end

  def deploy_ec2
    hugo_config = YAML.load_file("config/hugo.yml")
    app_config = YAML.load_file("config/#{application}.yml")
    
    commands = []
    #commands << "git clone #{@@hugo_config['git']} ~/hugo-repos"
    commands << "cd hugo-repos && git fetch && git merge"
    commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'

    dna = { :run_list => app_config['run_list'],
      :package_list => app_config['package_list'] || {},
      :gem_list => app_config['gem_list'] || {},
      :application => self.application, 
      :customer => self.cloud,
      :database => { 
        :uri => self.db.uri, 
        :user => self.db.user, 
        :password => self.db.password }, 
      :web => { :port => self.port, :ssl => self.ssl }, 
      :git => hugo_config['git'],
      :github => hugo_config['github'],
      :access_key => Ec2::ACCESS_KEY,
      :secret_key => Ec2::SECRET_KEY,
      :app => app_config['app'] || nil
    }
    
    lb.instances.each do |i|
      Ec2.find(i).ssh(commands, dna)
    end
  end
  
  def delete_ec2(i=1)
    i.times do 
      instance_id = lb.instances[0]
      lb.remove(instance_id)
      Hugo::Ec2.find(instance_id).destroy
    end  
  end
  

end