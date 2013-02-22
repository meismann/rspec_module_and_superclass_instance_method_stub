# rspec-module-and-superclass-instance-method-stub

## Features

Allows you to stub instance methods on already included modules (such as Rails' view helpers). Allows you to stub instance methods in a class but keep the overriding method in a subclass (which is not possible with RSpec's any_instance.stub)

## Installation

    # Gemfile, group :test
    gem 'rspec-module-and-superclass-instance-method-stub', git: 'https://github.com/meismann/rspec-module-and-superclass-instance-method-stub.git'
    
## Usage

### Stubbing an instance method of a Module

This Gem supports several syntaxes known from RSpec to stub methods of classes. With this in mind, the following pieces of code do what you expect:

    UserHelper.any_including_instance.stub formatted_birthday: '2nd of May Anno Domini 1535'
    
    UserHelper.any_including_instance.stub :formatted_birthday do
      '2nd of May Anno Domini 1535'
    end

    UserHelper.any_including_instance.stub :formatted_birthday do |date|
      date.to_s
    end
    
    UserHelper.any_including_instance.stub(:formatted_birthday).and_return '2nd of May Anno Domini 1535'
    
    UserHelper.any_including_instance.stub(:formatted_birthday).and_return do
      '2nd of May Anno Domini 1535'
    end

    UserHelper.any_including_instance.stub(:formatted_birthday).and_return do |date|
      date.to_s
    end
    
### Stubbing an instance of a class (overridably)

The syntax here is the same as when »Stubbing an instance method of a Module«. Just use ```any_non_overriding_instance``` instead of ```any_including_instance```. These two methods are indeed even aliases. The differentiation is made only for the obvious reason of expressiveness.
