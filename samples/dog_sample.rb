require "factory_girl"
require "factory_girl_extensions"

class Dog
  attr_accessor :name, :breed, :is_saved

  def save
    self.is_saved = "Saved via #save"
  end

  def save!
    self.is_saved = "Saved via #save!"
  end
end

FactoryGirl.define do
  factory :dog do
    name  "Rover"
    breed "Golden Retriever"
  end
end

def print_and_eval_code(code)
  puts ">> #{code}"
  puts "=> #{eval(code).inspect}"
rescue Exception => ex
  puts "Exception raised: #{ex.inspect}"
end

print_and_eval_code "Dog.build"
print_and_eval_code "Dog.build(:name => 'Spot')"
print_and_eval_code "Dog.gen"
print_and_eval_code "Dog.gen(:name => 'Spot')"
print_and_eval_code "Dog.gen!"
print_and_eval_code "Dog.gen!(:name => 'Spot')"
print_and_eval_code "Dog.attrs"
print_and_eval_code "'a string'.gen"
