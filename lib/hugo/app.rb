module Hugo; end

class Hugo::App
  include Singleton
  include Hugo::Mixin::ParamsValidate


  def servers(instances=1)
    if lb
      if instances > lb.instances.length
        build_ec2(instances - lb.instances.length)
      elsif instances < lb.instances.length
        delete_ec2(lb.instances.length - instances)
      end    
    end
  end
  
  def setup
    lb.instances.each do |i|
      setup_ec2(i)
    end
    puts "Setup Completed"
  end
  
  def deploy
    deploy_ec2
    puts "Deploy Completed"    
  end
  
  def destroy
    lb.instances.each do |i|
      Hugo::Aws::Ec2.find(i).destroy
    end    
  end
  
  
  def name(arg=nil)
    set_or_return(:name, arg, :kind_of => [String]) 
  end
  
  def lb(arg=nil)
    set_or_return(:lb, arg, :kind_of => [Hugo::Aws::Elb]) 
  end
  
  def db(arg=nil)
    set_or_return(:db, arg, :kind_of => [Hugo::Aws::Rds]) 
  end
  
  def uri(arg=nil)
    set_or_return(:uri, arg, :kind_of => [String]) 
  end
  
  def type(arg=nil)
    set_or_return(:type, arg, :kind_of => [String]) 
  end

  def zone(arg=nil)
    set_or_return(:zone, arg, :kind_of => [String]) 
  end

  def image_id(arg=nil)
    set_or_return(:image_id, arg, :kind_of => [String]) 
  end

  def port(arg=nil)
    set_or_return(:port, arg, :kind_of => [String]) 
  end

  def ssl(arg=nil)
    set_or_return(:ssl, arg, :kind_of => [String]) 
  end

  def application(arg=nil)
    set_or_return(:application, arg, :kind_of => [String]) 
  end

  def security_group(arg=nil)
    set_or_return(:security_group, arg, :kind_of => [String]) 
  end
    
  def cloud_name(arg=nil)
    set_or_return(:cloud_name, arg, :kind_of => [String])
  end
  
  def key_name(arg=nil)
    set_or_return(:key_name, arg, :kind_of => [String])
  end

  def cookbook(arg=nil)
    set_or_return(:cookbook, arg, :kind_of => [String])
  end
  
  def key_path(arg=nil)
    set_or_return(:key_pair_file, arg, :kind_of => [String])    
  end

  def port(arg=nil)
    set_or_return(:port, arg, :kind_of => [String])    
  end
  
  def github_url(arg=nil)
    set_or_return(:github_url, arg, :kind_of => [String])        
  end
  
  def privatekey(arg=nil)
    set_or_return(:privatekey, arg, :kind_of => [String])            
  end

  def publickey(arg=nil)
    set_or_return(:publickey, arg, :kind_of => [String])            
  end

  def gem_list(arg=nil)
    set_or_return(:gem_list, arg, :kind_of => [Array])            
  end

  def package_list(arg=nil)
    set_or_return(:package_list, arg, :kind_of => [Array])            
  end
  
  def run_list(arg=nil)
    set_or_return(:run_list, arg, :kind_of => [Array])                
  end
  
  def deploy_info(arg=nil)
    set_or_return(:deploy_info, arg, :kind_of => [Hash])                    
  end
  
  
  
  
  
private

  def build_ec2(i=1)
    i.times do
      instance_id = create_ec2
      #setup_ec2(instance_id)
      lb.add(instance_id)
    end
  end
  
  def create_ec2
    ec2 = Hugo::Aws::Ec2.new(:type => type, 
                    :zone => zone, 
                    :image_id => image_id,
                    :key_name => key_name,
                    :security_group => "default").create
  
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
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo apt-get update -y; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo apt-get install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb build-essential git-core xfsprogs -y; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz && tar zxf rubygems-1.3.5.tgz; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else cd rubygems-1.3.5 && sudo ruby setup.rb && sudo ln -sfv /usr/bin/gem1.8 /usr/bin/gem; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem update --system; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem install gemcutter --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem install chef ohai --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem source -a http://gems.github.com; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem install chef-deploy --no-ri --no-rdoc; fi'
    commands << 'if [ -d "./hugo-repos" ]; then echo "setup already run"; else sudo gem install git --no-ri --no-rdoc; fi'
    commands << "if [ -d \"./hugo-repos\" ]; then echo \"setup already run\"; else git clone #{self.cookbook} ~/hugo-repos; fi"
    Hugo::Aws::Ec2.find(instance_id).ssh(commands, nil, File.join(key_path, key_name))
  end
  
  def deploy_ec2
  
    commands = []
    commands << "cd hugo-repos && git pull"
    commands << 'sudo chef-solo -c /home/ubuntu/hugo-repos/config/solo.rb -j /home/ubuntu/dna.json'
    
    ports = [port]
    ports << ssl unless ssl.nil?
      
    database_info = {}
    database_info = { 
      :uri => db.uri, 
      :name => db.db,
      :user => db.user, 
      :password => db.password } unless db.nil?
      
    dna = { :run_list => run_list,
      :package_list => package_list,
      :gem_list => gem_list,

      :application => name, 
      :customer => cloud_name,
      :database => database_info, 
      :web => { :port => port, :ssl => ssl }, 
      :git => cookbook,
      :github => {  :url => github_url, 
                    :publickey => publickey, 
                    :privatekey => privatekey},
      :access_key => Hugo::Aws::Ec2::ACCESS_KEY,
      :secret_key => Hugo::Aws::Ec2::SECRET_KEY,
      :apache => { :listen_ports =>  ports },
      :app => deploy_info
    }
  
    lb.instances.each do |i|
      Hugo::Aws::Ec2.find(i).ssh(commands, dna, File.join(key_path, key_name))
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
