# DO NOT MODIFY THIS FILE
module Bundler
  LOAD_PATHS = ["/usr/local/lib/ruby/gems/1.8/gems/xml-simple-1.0.12/lib", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-2.3.5/lib", "/usr/local/lib/ruby/gems/1.8/gems/builder-2.1.2/lib", "/usr/local/lib/ruby/gems/1.8/gems/i18n-0.3.3/lib", "/usr/local/lib/ruby/gems/1.8/gems/json-1.2.0/ext/json/ext", "/usr/local/lib/ruby/gems/1.8/gems/json-1.2.0/ext", "/usr/local/lib/ruby/gems/1.8/gems/json-1.2.0/lib", "/Users/twilson63/.bundle/gems/net-ssh-2.0.19/lib", "/Users/twilson63/.bundle/gems/rspec-1.3.0/lib", "/usr/local/lib/ruby/gems/1.8/gems/activeresource-2.3.5/lib", "/usr/local/lib/ruby/gems/1.8/gems/zerigo_dns-1.1.2/lib", "/Users/twilson63/.bundle/gems/amazon-ec2-0.9.0/lib"]
  AUTOREQUIRES = {:test=>["rspec"], :default=>["amazon-ec2", "net-ssh", "json", "builder", "i18n", "activesupport", "activeresource", "zerigo_dns"]}

  def self.setup(*groups)
    LOAD_PATHS.each { |path| $LOAD_PATH.unshift path }
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      AUTOREQUIRES[group].each { |file| Kernel.require file }
    end
  end

  # Setup bundle when it's required.
  setup
end
