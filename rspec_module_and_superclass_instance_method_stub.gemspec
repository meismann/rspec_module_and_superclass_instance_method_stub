lib_dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

Gem::Specification.new do |s|
  s.name = 'rspec-module-and-superclass-instance-method-stub'
  s.version = '1.0.4'
  s.authors = ['Martin Eismann']
  s.email = ['martin.eismann@injixo.com']
  s.homepage = 'https://github.com/meismann/rspec-module-and-superclass-instance-method-stub'
  s.summary = "Allows you to stub instance methods on already included modules (such as Rails' view helpers). Allows you to stub instance methods in a class but keep the overriding method in a subclass (which is not possible with RSpec's any_instance.stub)"

  s.files = Dir["{lib}/**/*"] + ["README.md"]
  s.require_paths = ['lib']
  s.test_files = Dir['spec/*']

  s.add_dependency 'rspec-rails'
end