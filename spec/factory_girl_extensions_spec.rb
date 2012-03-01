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
  extend FactoryGirlExtensions

  attr_accessor :name, :saved

  def save
    self.saved = true
  end

  def saved?
    saved == true
  end

  def save!
    raise "Called save!" unless name == "Valid Name"
    self.saved = true
  end
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

    dog.saved = false
    expect { dog.save! }.to raise_error(RuntimeError, /Called save!/)
    dog.saved?.should == false

    dog.name = "Valid Name" # this let's you call save!
    dog.save!
    dog.saved?.should == true
  end
end

describe FactoryGirl::Syntax::ObjectMethods do

  it "raises useful Exception when no matching factory can be found" do
    expect { Dog.build(:foo, :bar)      }.to raise_error(ArgumentError, %{Could not find factory for "dog" with [:foo, :bar]})
    expect { Dog.generate(:foo, :bar)   }.to raise_error(ArgumentError, %{Could not find factory for "dog" with [:foo, :bar]})
    expect { Dog.attributes(:foo, :bar) }.to raise_error(ArgumentError, %{Could not find factory for "dog" with [:foo, :bar]})
  end

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

    it "with prefix and suffix (reversed works too)" do
      @dog = Dog.build(:with_toys, :awesome)
      @dog.name.should == "Awesome Dog with toys"
    end

    it "cannot pass more than 2 prefix/suffix" do
      expect { Dog.build(:one, :two, :three) }.to raise_error(ArgumentError, %{Don't know how to find factory for "dog" with [:one, :two, :three]})
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

      Dog.gen!(:name => "Valid Name").name.should == "Valid Name"
      Dog.gen!(:name => "Valid Name"){|d| d.name += " FOO" }.name.should == "Valid Name FOO"
    end

    it "without arguments" do
      @dog = Dog.generate
      @dog.name.should == "Rover"
    end

    it "with overrides" do
      @dog = Dog.generate(:name => "Spot")
      @dog.name.should == "Spot"
    end

    it "yields the built instance to block (after calling #save on it)" do
      @dog = Dog.generate(:name => "Spot") do |dog|
        dog.should be_saved
        dog.name += " Remover"
      end
      @dog.name.should == "Spot Remover"
    end

    it "generate! yields the resulting instance (after calling save! on it)" do
      Dog.gen!(:name => "Valid Name") do |dog|
        dog.should be_saved
      end
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

    it "with prefix and suffix (reversed works too)" do
      @dog = Dog.generate(:with_toys, :awesome)
      @dog.name.should == "Awesome Dog with toys"
    end

    it "cannot pass more than 2 prefix/suffix" do
      expect { Dog.generate(:one, :two, :three) }.to raise_error(ArgumentError, %{Don't know how to find factory for "dog" with [:one, :two, :three]})
    end
  end

  describe "#attributes" do
    it "without arguments" do
      Dog.attributes.should == { :name => "Rover" }
    end

    it "can call #attrs as a shortcut" do
      Dog.attrs.should == { :name => "Rover" }
    end

    it "with overrides" do
      Dog.attributes(:name => "Spot").should == { :name => "Spot" }
    end

    it "yields the built instance to block" do
      Dog.attributes(:name => "Spot"){|hash| hash[:name] += " Remover" }.should == { :name => "Spot Remover" }
    end

    it "with prefix" do
      Dog.attributes(:awesome).should == { :name => "Awesome Dog" }
    end

    it "with suffix" do
      Dog.attributes(:with_toys).should == { :name => "Dog with toys" }
    end

    it "with prefix and suffix" do
      Dog.attributes(:awesome, :with_toys).should == { :name => "Awesome Dog with toys" }
    end

    it "with prefix and suffix (reversed works too)" do
      Dog.attributes(:with_toys, :awesome).should == { :name => "Awesome Dog with toys" }
    end

    it "cannot pass more than 2 prefix/suffix" do
      expect { Dog.attributes(:one, :two, :three) }.to raise_error(ArgumentError, %{Don't know how to find factory for "dog" with [:one, :two, :three]})
    end
  end
end
