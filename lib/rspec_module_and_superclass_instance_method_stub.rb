require 'rspec'

def nice value
  case value
  when nil
    'nil'
  when Fixnum, TrueClass, FalseClass, Class, Array, Hash
    value
  when Symbol
    ":#{value}"
  when Regexp
    value.inspect
  else
    "'#{value}'"
  end
end


class Module
  
  @@stubbed_modules = []
  
  def any_including_instance
    stubbing_provider
  end
  
  def real_owner_of(method)
    instance_method(method).owner
  end
  
  def self.clean_stubs
    @@stubbed_modules.each do |stubbed_module|
      stubbed_module.instance_methods.each do |instance_method|
        restore_pristine(stubbed_module, instance_method) if instance_method.to_s =~ /^__.+_stubbed$/
      end
    end
  end
  
  protected
  
  def stubbing_provider
    modewl = self
    stub = lambda do |arg, &block|
      case arg
      when Hash
        arg.each do |method, ret_val|
          (@@stubbed_modules << modewl.real_owner_of(method)).uniq!
          modewl.real_owner_of(method).send :alias_method, "__#{method}_stubbed".to_sym, method
          modewl.real_owner_of(method).send(:define_method, method){ |*args| ret_val }
        end
      when Symbol
        (@@stubbed_modules << modewl.real_owner_of(arg)).uniq!
        modewl.real_owner_of(arg).send :alias_method, "__#{arg}_stubbed".to_sym, arg
        if block
          modewl.real_owner_of(arg).send :define_method, arg do |*args|
            block.call *args
          end
        else
          replace_method_block = Proc.new{}
          (o = Object.new).define_singleton_method :and_return do |ret_val = nil, &block|
            replace_method_block = if block
              block
            else
              ->(*args){ ret_val }
            end
          end
          modewl.real_owner_of(arg).send :define_method, arg do |*args|
            replace_method_block.call *args
          end
          o
        end
      else
        raise "Call #{@calling_type}.#{@calling_method}#stub with a Hash or a Symbol"
      end
    end
    (o = Object.new).define_singleton_method :stub, stub
    o.instance_variable_set :@calling_method, caller.first.sub(/.*`(.+)'.*/, '\1')
    o.instance_variable_set :@calling_type, self.class
    o
  end
  
  class << self
    private
    
    def restore_pristine(stubbed_module, instance_method_alias)
      return unless stubbed_module == stubbed_module.real_owner_of(instance_method_alias)
      instance_method = instance_method_alias.to_s.gsub(/^__(.+)_stubbed$/, '\1').to_sym
      stubbed_module.send :remove_method, instance_method
      stubbed_module.send :alias_method, instance_method, instance_method_alias
      stubbed_module.send :remove_method, instance_method_alias
    end
  end
  
  RSpec.configure do |config|
    config.after(:each) do
      Module.clean_stubs
    end
  end
end

class Class
  
  def any_non_overriding_instance
    stubbing_provider
  end
  
end
