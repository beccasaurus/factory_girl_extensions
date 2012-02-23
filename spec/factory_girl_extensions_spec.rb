# If you require "factory_girl_extensions", it automatically extends Object with these extensions.
#
# If you require "factory_girl_extensions/core", it doesn't automatically include extensions anywhere 
# so you can choose which classes/objects you want to extend to get the gen/build/etc methods.
require "factory_girl_extensions/core"

# Required after factory_girl_extensions to ensure that factory_girl_extensions doesn't 
# blow up if factory_girl hasn't been required yet.
require "factory_girl"

require "rspec"

describe "Basic factory generation" do

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

  it "Dog class should act as expected" do
    dog = Dog.new
    dog.name.should be_nil

    dog.name = "Rover"
    dog.name.should == "Rover"

    dog.saved?.should == false
    dog.save
    dog.saved?.should == true

    expect { dog.save! }.to raise_error(RuntimeError, /Called save!/)
  end

  it "should raise a useful Exception when trying to build a Factory that cannot be found"

  describe "#build" do

    after do
      # No versions of #build should save the instance
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

    it "yields the built instance to a block" do
      @dog = Dog.build(:name => "Spot"){|d| d.name += " Remover" }
      @dog.name.should == "Spot Remover"
    end

    it "can build factory with prefix" do
      @dog = Dog.build(:awesome)
      @dog.name.should == "Awesome Dog"
    end

    it "can build factory with suffix" do
      @dog = Dog.build(:with_toys)
      @dog.name.should == "Dog with toys"
    end

    it "can build factory with prefix and suffix" do
      @dog = Dog.build(:awesome, :with_toys)
      @dog.name.should == "Awesome Dog with toys"
    end

    it "currently doesn't support more than 2 prefix/suffixes being passed" do
      expect { Dog.build(:one, :two, :three) }.to raise_error(ArgumentError, /Don't know how to find factory for "dog" with \[:one, :two, :three\]/)
    end
  end

  # #gen is a shortcut for #generate
  # %w[ generate gen ].each do |method|
  #   describe "#gen" do
  #   end
  #
  #   describe "#gen!" do
  #   end
  # end
end
