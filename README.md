rspec-module-and-superclass-instance-method-stub
================================================

Allows you to stub instance methods on already included modules (such as Rails' view helpers). Allows you to stub instance methods in a class but keep the overriding method in a subclass (which is not possible with RSpec's any_instance.stub)