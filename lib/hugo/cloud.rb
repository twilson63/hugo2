module Hugo; end
  
class Hugo::Cloud
  include Singleton
  DEFAULT_ZONE = 'us-east-1c'
  DEFAULT_IMAGE_ID = 'ami-1515f67c'
  DEFAULT_KEY_NAME = 'ec2-keypair'
  DEFAULT_COOKBOOK = 'git://github.com/twilson63/hugo-cookbooks.git'
  
  attr_accessor :name, :uri, :type, :zone, :image_id, 
                :key_name, :db, :lb, :instances,
                :port, :ssl, :application, :cookbook,
                :github_url, :publickey, :privatekey,
                :gem_list, :package_list, :run_list, :app_info
                  
  def initialize
    self.zone = DEFAULT_ZONE
    self.image_id = DEFAULT_IMAGE_ID
    self.key_name = DEFAULT_KEY_NAME
    self.instances = 1
    self.cookbook = DEFAULT_COOKBOOK
  end

  def database(name, &block)
    database = Hugo::Database.instance
    database.instance_eval(&block) if block_given? 
    database.name = name

    self.db = database.deploy
    self.db
  end
  
  def balancer(&block)
    balancer = Hugo::Balancer.instance
    balancer.name = self.name
    balancer.instance_eval(&block) if block_given? 
    self.port = balancer.port
    self.ssl = balancer.ssl_port
    self.lb = balancer.deploy
    self.lb
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
    ec2 = Hugo::Aws::Ec2.new(:type => self.type, 
                    :zone => self.zone, 
                    :image_id => self.image_id,
                    :key_name => self.key_name).create
    new_ec2 = nil
    loop do
      new_ec2 = Hugo::Aws::Ec2.find(ec2.name)
      if new_ec2.status == "running"
        break
      end
      sleep 5
    end
    
    sleep 10
    new_ec2.name
  end

  def setup_ec2(instance_id)
    
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
    commands << "git clone #{self.cookbook} ~/hugo-repos"
    # Setup base role
    dna = { :run_list => ["role[web-base]"],
      :package_list => self.package_list,
      :gem_list => self.gem_list,
      :git => self.cookbook,
      :github => {  :url => self.github_url, 
                    :publickey => self.publickey, 
                    :privatekey => self.privatekey},
      :access_key => Hugo::Aws::Ec2::ACCESS_KEY,
      :secret_key => Hugo::Aws::Ec2::SECRET_KEY,
      :apache => { :listen_ports => [self.port, self.ssl] }

    }

    commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'
    Hugo::Aws::Ec2.find(instance_id).ssh(commands, dna)
  end

  def deploy_ec2
    
    commands = []
    #commands << "git clone #{@@hugo_config['git']} ~/hugo-repos"
    commands << "cd hugo-repos && git fetch && git merge"
    commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'

    dna = { :run_list => self.run_list,
      :package_list => self.package_list,
      :gem_list => self.gem_list,
      :application => self.application, 
      :customer => self.name,
      :database => { 
        :uri => self.db.uri, 
        :user => self.db.user, 
        :password => self.db.password }, 
      :web => { :port => self.port, :ssl => self.ssl }, 
      :git => self.cookbook,
      :github => {  :url => self.github_url, 
                    :publickey => self.publickey, 
                    :privatekey => self.privatekey},
      :access_key => Hugo::Aws::Ec2::ACCESS_KEY,
      :secret_key => Hugo::Aws::Ec2::SECRET_KEY,
      :app => self.app_info
    }
    
    lb.instances.each do |i|
      Hugo::Aws::Ec2.find(i).ssh(commands, dna)
    end
  end
  
  def delete_ec2(i=1)
    i.times do 
      instance_id = lb.instances[0]
      lb.remove(instance_id)
      Hugo::Aws::Ec2.find(instance_id).destroy
    end  
  end
  

end