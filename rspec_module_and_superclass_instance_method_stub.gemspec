# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rspec_module_and_superclass_instance_method_stub"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Eismann"]
  s.date = "2013-04-16"
  s.email = ["martin.eismann@injixo.com"]
  s.files = ["lib/rspec_module_and_superclass_instance_method_stub.rb", "README.md", "spec/rspec_module_and_superclass_instance_method_stub_spec.rb"]
  s.homepage = "https://github.com/meismann/rspec_module_and_superclass_instance_method_stub"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.0.preview2"
  s.summary = "Allows you to stub instance methods on already included modules (such as Rails' view helpers). Allows you to stub instance methods in a class but keep the overriding method in a subclass (which is not possible with RSpec's any_instance.stub)"
  s.test_files = ["spec/rspec_module_and_superclass_instance_method_stub_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec-rails>, [">= 0"])
    else
      s.add_dependency(%q<rspec-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec-rails>, [">= 0"])
  end
end
