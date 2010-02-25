module Hugo; end

class Hugo::App
  include Singleton
  include Hugo::Mixin::ParamsValidate
  
  AMI = ENV['EC2_AMI_ID'] || 'ami-1515f67c'
  ZONE = "us-east-1c"
  TYPE = "m1.small"
  

  attr_accessor :dna
  
  # How many servers do you want in your cloud
  # This function will give and take away servers
  def servers(instances=1)
    if lb
      if instances > lb.instances.length
        build_ec2(instances - lb.instances.length)
      elsif instances < lb.instances.length
        delete_ec2(lb.instances.length - instances)
      end    
    else
      instance(build_ec2(1)) unless instance
    end
  end
  
  # Setup will install chef-solo on server instance
  def setup
    if lb
      lb.instances.each do |i|
        setup_ec2(i)
      end
    else
      setup_ec2(instance)
    end
    # puts "Setup Completed"
  end
  
  # deploy will run you json with chef-sole against your cookbooks
  def deploy
    raise ArgumentError, "app.key_name Required" unless key_name
    raise ArgumentError, "app.key_path Required" unless key_path
    raise ArgumentError, "app.cookbook Required" unless cookbook
    raise ArgumentError, "app.run_list Required" unless run_list
    
    deploy_ec2
    #puts "Deploy Completed"    
  end
  
  # will kill all app servers
  def destroy
    if lb
      lb.instances.each do |i|
        Hugo::Aws::Ec2.find(i).destroy
      end    
    else
      Hugo::Aws::Ec2.find(instance).destroy
    end
    
  end
  
  def clear
    @key_name = nil
    @key_path = nil
    @cookbook = nil
    @run_list = nil
  end
  
  
  # Dyanamically add recipes to your json
  def add_recipe(name, options=nil)
    run_list [] if run_list.nil?
    run_list << "recipe[#{name}]"
    if options
      empty_hash = {}
      self.dna = {} if self.dna.nil?
      self.dna.merge!(options)
    end
  end

  # Set the instance if you only are deploying one server
  def instance(arg=nil)
    set_or_return(:instance, arg, :kind_of => [String]) 
  end
    
  # Name of app - should relate to github repository
  def name(arg=nil)
    set_or_return(:name, arg, :kind_of => [String]) 
  end
  
  # Load Balancer Object
  def lb(arg=nil)
    set_or_return(:lb, arg, :kind_of => [Hugo::Aws::Elb]) 
  end
  
  # Database Object
  def db(arg=nil)
    set_or_return(:db, arg, :kind_of => [Hugo::Database]) 
  end
  
  # URI of 
  # def uri(arg=nil)
  #   set_or_return(:uri, arg, :kind_of => [String]) 
  # end
  
  # def type(arg=nil)
  #   set_or_return(:type, arg, :kind_of => [String]) 
  # end

  def zone(arg=nil)
    set_or_return(:zone, arg, :kind_of => [String]) 
  end

  def image_id(arg=nil)
    set_or_return(:image_id, arg, :kind_of => [String]) 
  end

  def security_group(arg=nil)
    set_or_return(:security_group, arg, :kind_of => [String]) 
  end
      
  def key_name(arg=nil)
    set_or_return(:key_name, arg, :kind_of => [String])
  end

  def cookbook(arg=nil)
    set_or_return(:cookbook, arg, :kind_of => [String])
  end
  
  def key_path(arg=nil)
    set_or_return(:key_path, arg, :kind_of => [String])    
  end
    
  def run_list(arg=nil)
    set_or_return(:run_list, arg, :kind_of => [Array])                
  end
    
  
  def help
    x = <<HELP

Hugo app 
-----------------
There are two ways to run hugo app, a single instance mode, or 
with a balancer.  If you do not use a balancer, then after your 
initial run, which creates the server instance, you need to enter
the server instance into your config, so it will not create a new
ec2 everytime

Required attributes
-----------------
key_name
key_path
cookbook
run_list

Methods
------------------
servers

deploy

add_recipe

destroy

help

Optional Attributes
-----------------

instance
lb
db
uri
type
zone
image_id



HELP
    puts x
    x
  end  
  
  
private

  def build_ec2(i=1)
    instance_id = nil
    i.times do
      instance_id = create_ec2
      #setup_ec2(instance_id)
      lb.add(instance_id) if lb
    end
    instance_id
  end
  
  def create_ec2
    ec2 = Hugo::Aws::Ec2.new(:type => type || TYPE, 
                    :zone => zone || ZONE, 
                    :image_id => image_id || AMI,
                    :key_name => key_name,
                    :security_group => security_group || "default").create
  
    new_ec2 = nil
    sleep 10
    loop do
      new_ec2 = Hugo::Aws::Ec2.find(ec2.name)
      puts new_ec2.status
      if new_ec2.status == "running"
        break
      end
      sleep 30
    end
  
    sleep 10
    new_ec2.name
  end
  
  def setup_ec2(instance_id)
    
    commands = []
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo apt-get update -y; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo apt-get install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb build-essential git-core xfsprogs -y; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz && tar zxf rubygems-1.3.5.tgz; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else cd rubygems-1.3.5 && sudo ruby setup.rb && sudo ln -sfv /usr/bin/gem1.8 /usr/bin/gem; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem update --system; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem install gemcutter --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem install chef ohai --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem source -a http://gems.github.com; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem install chef-deploy --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "."; else sudo gem install git --no-ri --no-rdoc; fi'
    commands << "if [ -d \"./hugo-repos\" ]; then echo \".\"; else git clone #{self.cookbook} ~/hugo-repos; fi"
    ec2 = Hugo::Aws::Ec2.find(instance_id)
    #puts ec2.uri
    ec2.ssh(commands, nil, File.join(key_path, key_name))
  end
  
  def deploy_ec2
  
    commands = []
    commands << "cd hugo-repos && git reset --hard && git pull"
    commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'
        
    
    self.dna = {} if self.dna.nil?
    self.dna.merge!(
      :run_list => run_list,
      :git => cookbook,
      :access_key => Hugo::Aws::Ec2::ACCESS_KEY,
      :secret_key => Hugo::Aws::Ec2::SECRET_KEY,
      :database => db ? db.info : {} 
    )
          
    if lb
      lb.instances.each do |i|
        Hugo::Aws::Ec2.find(i).ssh(commands, dna, File.join(key_path, key_name))
      end
    else
      Hugo::Aws::Ec2.find(instance).ssh(commands, dna, File.join(key_path, key_name))      
    end
    
  end
  
  def delete_ec2(i=1)
    i.times do 
      instance_id = lb.instances[0]
      Hugo::Aws::Ec2.find(instance_id).destroy
      #lb.remove(instance_id)

    end  
  end
    

end
