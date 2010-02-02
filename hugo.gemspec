# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hugo}
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Wilson", "Barrett Little"]
  s.date = %q{2010-02-02}
  s.description = %q{A easy to understand DSL that makes it dirt simple to deploy to the cloud.}
  s.email = %q{tom@jackhq.com}
  s.files = [
    "Rakefile",
     "lib/hugo.rb",
     "lib/hugo/app.rb",
     "lib/hugo/aws/ec2.rb",
     "lib/hugo/aws/elb.rb",
     "lib/hugo/aws/rds.rb",
     "lib/hugo/balancer.rb",
     "lib/hugo/cloud.rb",
     "lib/hugo/database.rb",
     "lib/hugo/mixin/params_validate.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/twilson63/hugo}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Deploy Your Rack Apps to Cloud}
  s.test_files = [
    "spec/lib/hugo/app_spec.rb",
     "spec/lib/hugo/aws/ec2_spec.rb",
     "spec/lib/hugo/aws/elb_spec.rb",
     "spec/lib/hugo/aws/rds_spec.rb",
     "spec/lib/hugo/balancer_spec.rb",
     "spec/lib/hugo/database_spec.rb",
     "spec/lib/hugo_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amazon-ec2>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<amazon-ec2>, ["= 0.7.5"])
      s.add_runtime_dependency(%q<json>, ["= 1.2.0"])
      s.add_runtime_dependency(%q<net-ssh>, ["= 2.0.16"])
    else
      s.add_dependency(%q<amazon-ec2>, [">= 0"])
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<amazon-ec2>, ["= 0.7.5"])
      s.add_dependency(%q<json>, ["= 1.2.0"])
      s.add_dependency(%q<net-ssh>, ["= 2.0.16"])
    end
  else
    s.add_dependency(%q<amazon-ec2>, [">= 0"])
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<amazon-ec2>, ["= 0.7.5"])
    s.add_dependency(%q<json>, ["= 1.2.0"])
    s.add_dependency(%q<net-ssh>, ["= 2.0.16"])
  end
end

