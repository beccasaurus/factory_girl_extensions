# If you require "factory_girl_extensions", it automatically extends Object with these extensions.
#
# If you require "factory_girl_extensions/core", it doesn't automatically include extensions anywhere 
# so you can choose which classes/objects you want to extend to get the gen/build/etc methods.
require "factory_girl_extensions/core"

# Required after factory_girl_extensions to ensure that factory_girl_extensions doesn't 
# blow up if factory_girl hasn't been required yet.
require "factory_girl"

require "rspec"

# Example class
class Dog
  extend FactoryGirl::Syntax::ObjectMethods

  attr_accessor :name, :saved

  def save()   self.saved = true    end
  def saved?() saved == true        end
  def save!()  raise "Called save!" end
end

# Example factories
FactoryGirl.define do
  factory :dog do
    name "Rover"
  end

  factory :awesome_dog, :class => Dog do
    name "Awesome Dog"
  end

  factory :dog_with_toys, :class => Dog do
    name "Dog with toys"
  end

  factory :awesome_dog_with_toys, :class => Dog do
    name "Awesome Dog with toys"
  end
end

describe Dog do
  it "should act as expected" do
    dog = Dog.new
    dog.name.should be_nil

    dog.name = "Rover"
    dog.name.should == "Rover"

    dog.saved?.should == false
    dog.save
    dog.saved?.should == true

    expect { dog.save! }.to raise_error(RuntimeError, /Called save!/)
  end
end

describe FactoryGirl::Syntax::ObjectMethods do

  describe "#build" do
    after do
      @dog.should_not be_saved if @dog
    end

    it "without arguments" do
      @dog = Dog.build
      @dog.name.should == "Rover"
    end

    it "with overrides" do
      @dog = Dog.build(:name => "Spot")
      @dog.name.should == "Spot"
    end

    it "yields the built instance to block" do
      @dog = Dog.build(:name => "Spot"){|d| d.name += " Remover" }
      @dog.name.should == "Spot Remover"
    end

    it "with prefix" do
      @dog = Dog.build(:awesome)
      @dog.name.should == "Awesome Dog"
    end

    it "with suffix" do
      @dog = Dog.build(:with_toys)
      @dog.name.should == "Dog with toys"
    end

    it "with prefix and suffix" do
      @dog = Dog.build(:awesome, :with_toys)
      @dog.name.should == "Awesome Dog with toys"
    end

    it "cannot pass more than 2 prefix/suffix" do
      expect { Dog.build(:one, :two, :three) }.to raise_error(ArgumentError, /Don't know how to find factory for "dog" with \[:one, :two, :three\]/)
    end
  end

  describe "#generate" do
    after do
      @dog.should be_saved if @dog
    end

    it "can call #gen as a shortcut" do
      @dog = Dog.gen
      @dog.name.should == "Rover"
      @dog.should be_saved
    end

    it "can call with a bang to save! (to raise an Exception on failure)" do
      expect { Dog.generate! }.to raise_error(RuntimeError, /Called save!/)
      expect { Dog.gen!      }.to raise_error(RuntimeError, /Called save!/)
    end

    it "without arguments" do
      @dog = Dog.generate
      @dog.name.should == "Rover"
    end

    it "with overrides" do
      @dog = Dog.generate(:name => "Spot")
      @dog.name.should == "Spot"
    end

    it "yields the built instance to block" do
      @dog = Dog.generate(:name => "Spot"){|d| d.name += " Remover" }
      @dog.name.should == "Spot Remover"
    end

    it "with prefix" do
      @dog = Dog.generate(:awesome)
      @dog.name.should == "Awesome Dog"
    end

    it "with suffix" do
      @dog = Dog.generate(:with_toys)
      @dog.name.should == "Dog with toys"
    end

    it "with prefix and suffix" do
      @dog = Dog.generate(:awesome, :with_toys)
      @dog.name.should == "Awesome Dog with toys"
    end

    it "cannot pass more than 2 prefix/suffix" do
      expect { Dog.generate(:one, :two, :three) }.to raise_error(ArgumentError, /Don't know how to find factory for "dog" with \[:one, :two, :three\]/)
    end
  end
end
