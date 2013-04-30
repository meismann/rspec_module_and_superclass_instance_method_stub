require 'rspec_module_and_superclass_instance_method_stub'

module M
  def m1
    'm1 in M'
  end
  def m2 arg
    'm2 in M'
  end
end

class ClassIncludingAModuleWithStubbedMethods
  include M
end

module MM
  include M
end

class ClassIncludingAModuleWithNestedStubbedMethods
  include MM
end

class IclM; include M; end
class IclMM; include MM; end

shared_context 'giving a shit about arity when calling' do |*methods|
  
  methods.each do |method|
    example method do
      subject.method(method).arity.should == -1
    end
  end
  
end

def check_pristine_state
  [ClassIncludingAModuleWithStubbedMethods, ClassIncludingAModuleWithNestedStubbedMethods, M, MM].each do |m|
    stubs = m.instance_methods.select{ |meth| meth.to_s =~ /^__.+_stubbed$/ }
    raise "Module #{m} still has stubbed methods: #{stubs} in before-hook" if stubs.any?
  end
  [ClassIncludingAModuleWithNestedStubbedMethods,
    ClassIncludingAModuleWithStubbedMethods, IclM, IclMM].each do |m|
      m1 = m.new.m1
      m2 = m.new.m2 nil
      error_for(m, :m1, m1) unless m1 == 'm1 in M'
      error_for(m, :m2, m2) unless m2 == 'm2 in M'
  end
end

def error_for(mod, meth, res)
  raise "#{mod}##{meth} still results in #{nice res}"
end


describe 'When stubbing the methods of a module' do
  context '--when #stub got called with' do
    [nil, 'a String', false, proc{}].each do |shit|
      it "#{nice(shit)}--should raise an error" do
        expect{ M.any_including_instance.stub shit }.to raise_error
      end
    end
  end
  context '--when other examples are run after the one calling #stub--' do
    [[ClassIncludingAModuleWithStubbedMethods, M],
      [ClassIncludingAModuleWithNestedStubbedMethods, M],
      [ClassIncludingAModuleWithNestedStubbedMethods, MM]
    ].each do |klass, modewl|
      describe klass do
        no_after_hook_run_yet = true

        before :all do
          modewl.any_including_instance.stub m1: :check_unstub_in_after_hook
        end

        it 'should have returned to its pristine state I (only passing with II having passed!)' do
          if subject.m1 == :check_unstub_in_after_hook && no_after_hook_run_yet
            no_after_hook_run_yet = false
          else
            no_after_hook_run_yet = false
            subject.m1.should == 'm1 in M'
            subject.should_not respond_to :__m1_stubbed
          end
        end

        it 'should have returned to its pristine state II (only passing with I having passed!)' do
          if subject.m1 == :check_unstub_in_after_hook && no_after_hook_run_yet
            no_after_hook_run_yet = false
          else
            no_after_hook_run_yet = false
            subject.m1.should == 'm1 in M'
            subject.should_not respond_to :__m1_stubbed
          end
        end
      end
    end
  end
end

[[ClassIncludingAModuleWithStubbedMethods, M],
  [ClassIncludingAModuleWithNestedStubbedMethods, MM],
  [ClassIncludingAModuleWithNestedStubbedMethods, M]
].each do |klass, modewl|
  describe klass do

    before do
      check_pristine_state
    end

    describe "borrowing a stubbed method from an included Module (#{modewl})" do

      context '--when called with a Hash--' do
        before do
          modewl.any_including_instance.stub m1: 'stubbed m1'
          modewl.any_including_instance.stub m2: 'stubbed m2'
        end

        it_behaves_like 'giving a shit about arity when calling', :m1, :m2

        it 'should stub the methods given in the keys and make them return a default value as indicated in the corresponding Hash-value' do
          subject.m1.should == 'stubbed m1'
          subject.m2.should == 'stubbed m2'
        end
      end

      context '--when called with a block--' do
        before do
          modewl.any_including_instance.stub :m2 do |my_arg|
            @test_var = my_arg
          end
        end

        it_behaves_like 'giving a shit about arity when calling', :m2

        it 'should yield the block with the arguments given to the stubbed method' do
          subject.m2(:my_arg)
          @test_var.should == :my_arg
        end
      end

      context '--when stubbing is appended with #and_return' do
        context 'and a single parameter given to #and_return--' do
          before do
            modewl.any_including_instance.stub(:m2).and_return 7
          end

          it_behaves_like 'giving a shit about arity when calling', :m2

          it 'should return the "single parameter"' do
            subject.m2.should be 7
          end
        end

        context 'and a block given to #and_return--' do
          before do
            modewl.any_including_instance.stub(:m2).and_return do |my_arg|
              @test_var = my_arg
            end
          end

          it_behaves_like 'giving a shit about arity when calling', :m2

          it 'should yield the block with the arguments given to the stubbed method' do
            subject.m2 :my_arg
            @test_var.should be :my_arg
          end
        end
      end
    end
  end
end

class Super
  def test_instance_method
    :super_method
  end
end

class Inheriting < Super
  def test_instance_method
    :successfully_overriding
  end
end

describe 'When stubbing the methods of a class that is a super class to another one' do
  it 'should not affect overriding methods in children-classes' do
    Super.any_non_overriding_instance.stub test_instance_method: :check_unstub_in_after_hook
    Inheriting.new.test_instance_method.should be :successfully_overriding
  end
  
  context '--when #stub got called with' do
    [nil, 'a String', false, proc{}].each do |shit|
      it "#{nice(shit)}--should raise an error" do
        expect{ Super.any_non_overriding_instance.stub shit }.to raise_error
      end
    end
  end
  context '--when other examples are run after the one calling #stub--' do
    no_after_hook_run_yet = true
    
    before :all do
      Super.any_non_overriding_instance.stub test_instance_method: :check_unstub_in_after_hook
    end
    
    describe Super do
      
      it 'should have returned to its pristine state I (only passing with II having passed!)' do
        if subject.test_instance_method == :check_unstub_in_after_hook && no_after_hook_run_yet
          no_after_hook_run_yet = false
        else
          no_after_hook_run_yet = false
          subject.test_instance_method.should == :super_method
          subject.should_not respond_to :__test_instance_method_stubbed
        end
      end
      
      it 'should have returned to its pristine state II (only passing with I having passed!)' do
        if subject.test_instance_method == :check_unstub_in_after_hook && no_after_hook_run_yet
          no_after_hook_run_yet = false
        else
          no_after_hook_run_yet = false
          subject.test_instance_method.should == :super_method
          subject.should_not respond_to :__test_instance_method_stubbed
        end
      end
    end
  end
end

describe Super do

  before do
    check_pristine_state
  end

  shared_examples 'test class stubbing with method' do |instance_method_under_test|
    context '--when called with a Hash--' do
      before do
        subject.class.any_non_overriding_instance.stub instance_method_under_test => 'stubbed test_instance_method'
      end
      
      it_behaves_like 'giving a shit about arity when calling', instance_method_under_test
      
      it 'should stub the methods given in the keys and make them return a default value as indicated in the corresponding Hash-value' do
        subject.send(instance_method_under_test).should == 'stubbed test_instance_method'
      end
    end
    
    context '--when called with a block--' do
      before do
        subject.class.any_non_overriding_instance.stub instance_method_under_test do |my_arg|
          @test_var = my_arg
        end
      end
      
      it_behaves_like 'giving a shit about arity when calling', instance_method_under_test
      
      it 'should yield the block with the arguments given to the stubbed method' do
        subject.send instance_method_under_test, :my_arg
        @test_var.should == :my_arg
      end
    end
    
    context '--when stubbing is appended with #and_return' do
      context 'and a single parameter given to #and_return--' do
        before do
          subject.class.any_non_overriding_instance.stub(instance_method_under_test).and_return 7
        end
        
        it_behaves_like 'giving a shit about arity when calling', instance_method_under_test

        it 'should return the "single parameter"' do
          subject.send(instance_method_under_test).should be 7
        end
      end
      
      context 'and a block given to #and_return--' do
        before do
          subject.class.any_non_overriding_instance.stub(instance_method_under_test).and_return do |my_arg|
            @test_var = my_arg
          end
        end
        
        it_behaves_like 'giving a shit about arity when calling', instance_method_under_test

        it 'should yield the block with the arguments given to the stubbed method' do
          subject.send instance_method_under_test, :my_arg
          @test_var.should be :my_arg
        end
      end
    end
  end

  describe 'stubbing a self-owned instance method' do
    include_examples 'test class stubbing with method', :test_instance_method
  end
  
  describe 'stubbing an instance method inherited from a super class' do
    include_examples 'test class stubbing with method', :to_s
  end
  
end
