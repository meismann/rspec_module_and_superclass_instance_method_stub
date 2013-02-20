require 'stub_enhancer.rb'

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

describe 'When stubbing the methods of a module' do
  context '--when #stub got called with' do
    [nil, 'a String', false, proc{}].each do |shit|
      it "#{nice(shit)}--should raise an error" do
        expect{ M.any_including_instance.stub shit }.to raise_error
      end
    end
  end
  context '--when other examples are run after the one calling #stub--' do
    no_after_hook_run_yet = true
    
    before :all do
      M.any_including_instance.stub m1: :check_unstub_in_after_hook
    end
    
    subject { ClassIncludingAModuleWithStubbedMethods.new }
    
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

describe ClassIncludingAModuleWithStubbedMethods do

  describe 'a method coming from an included Module' do
  
    context '--when called with a Hash--' do
      before do
        M.any_including_instance.stub m1: 'stubbed m1'
        M.any_including_instance.stub m2: 'stubbed m2'
      end
      
      it 'should stub the methods given in the keys and make them return a default value as indicated in the corresponding Hash-value' do
        subject.m1.should == 'stubbed m1'
        subject.m2.should == 'stubbed m2'
      end
    end
    
    context '--when called with a block--' do
      before do
        M.any_including_instance.stub :m2 do |my_arg|
          @test_var = my_arg
        end
      end
      
      it 'should yield the block with the arguments given to the stubbed method' do
        subject.m2(:my_arg)
        @test_var.should == :my_arg
      end
    end
    
    context '--when stubbing is appended with #and_return' do
      context 'and a single parameter given to #and_return--' do
        before do
          M.any_including_instance.stub(:m2).and_return 7
        end
        
        it 'should return the "single parameter"' do
          subject.m2.should be 7
        end
      end
      
      context 'and a block given to #and_return--' do
        before do
          M.any_including_instance.stub(:m2).and_return do |my_arg|
            @test_var = my_arg
          end
        end
        
        it 'should yield the block with the arguments given to the stubbed method' do
          subject.m2 :my_arg
          @test_var.should be :my_arg
        end
      end
    end
  end
end

class Super
  def instance_method
    :super_method
  end
end

class Inheriting < Super
  def instance_method
    :successfully_overriding
  end
end

describe 'When stubbing the methods of a class that is a super class to another one' do
  it 'should not affect overriding methods in children-classes' do
    Super.any_non_overriding_instance.stub instance_method: :check_unstub_in_after_hook
    Inheriting.new.instance_method.should be :successfully_overriding
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
      Super.any_non_overriding_instance.stub instance_method: :check_unstub_in_after_hook
    end
    
    describe Super do
      
      it 'should have returned to its pristine state I (only passing with II having passed!)' do
        if subject.instance_method == :check_unstub_in_after_hook && no_after_hook_run_yet
          no_after_hook_run_yet = false
        else
          no_after_hook_run_yet = false
          subject.instance_method.should == :super_method
          subject.should_not respond_to :__instance_method_stubbed
        end
      end
      
      it 'should have returned to its pristine state II (only passing with I having passed!)' do
        if subject.instance_method == :check_unstub_in_after_hook && no_after_hook_run_yet
          no_after_hook_run_yet = false
        else
          no_after_hook_run_yet = false
          subject.instance_method.should == :super_method
          subject.should_not respond_to :__instance_method_stubbed
        end
      end
    end
  end
end

describe Super do

  describe 'a method coming from an included Module' do
  
    context '--when called with a Hash--' do
      before do
        subject.class.any_non_overriding_instance.stub instance_method: 'stubbed instance_method'
      end
      
      it 'should stub the methods given in the keys and make them return a default value as indicated in the corresponding Hash-value' do
        subject.instance_method.should == 'stubbed instance_method'
      end
    end
    
    context '--when called with a block--' do
      before do
        subject.class.any_non_overriding_instance.stub :instance_method do |my_arg|
          @test_var = my_arg
        end
      end
      
      it 'should yield the block with the arguments given to the stubbed method' do
        subject.instance_method(:my_arg)
        @test_var.should == :my_arg
      end
    end
    
    context '--when stubbing is appended with #and_return' do
      context 'and a single parameter given to #and_return--' do
        before do
          subject.class.any_non_overriding_instance.stub(:instance_method).and_return 7
        end
        
        it 'should return the "single parameter"' do
          subject.instance_method.should be 7
        end
      end
      
      context 'and a block given to #and_return--' do
        before do
          subject.class.any_non_overriding_instance.stub(:instance_method).and_return do |my_arg|
            @test_var = my_arg
          end
        end
        
        it 'should yield the block with the arguments given to the stubbed method' do
          subject.instance_method :my_arg
          @test_var.should be :my_arg
        end
      end
    end
  end
end
