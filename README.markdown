# FactoryGirl extensions

factory_girl_extensions is a simple set of extensions that I typically like to use on projects, when using factory_girl.

## Install

    gem install factory_girl_extensions

**NOTE**: factory_girl_extensions 2.0+ only works with factory_girl 2.0+. 
If you need to use an older version of factory_girl, install factory_girl_extensions < 2.0.

## Usage

```ruby
require 'factory_girl_extensions'

FactoryGirl.define do
  factory :user do
    name 'Bob Smith'
  end
end

# Creates a saved instance without raising (same as saving the result of FactoryGirl.build)
User.generate(:name => 'Johnny')

# Creates a saved instance and raises when invalid (same as FactoryGirl.create)
User.generate!

# Creates an unsaved instance (same as FactoryGirl.build)
User.build

# Creates an instance and yields it to the passed block
User.generate do |user|
  # ...do something with user...
end

# Creates and returns a Hash of attributes from this factory (same as FactoryGirl.attributes_for).
User.attributes

# A few short aliases are included for convenience.
User.gen
User.gen!
User.attrs

# Factories with custom prefix/suffixes are also supported.
FactoryGirl.define do
  factory :admin_user, :parent => :user do
    is_admin true
  end

  factory :user_with_profile, :parent => :user do
    profile_complete true
  end

  factory :admin_user_with_profile, :parent => :admin_user do
    profile_complete true
  end
end

# Generates the :admin_user factory
User.generate(:admin)
User.generate(:admin, :name => 'Cool Admin')

# Generates the :user_with_profile factory
User.generate(:with_profile)

# Generates the :admin_user_with_profile factory
User.generate(:admin, :with_profile)
User.generate(:admin, :with_profile, :name => 'Custom name')

# User.build and User.attributes also support these custom prefix/suffixes.
```

## Why User.gen instead of FactoryGirl(:user)?

Personally, I really dislike the `FactoryGirl(:user)` syntax.  When you have a lot of 
factories, it's hard to see the names of the actual model classes.  I don't like this:

```ruby
FactoryGirl(:user).should be_valid
FactoryGirl(:name, :string => 'something').should be_awesome
FactoryGirl(:comment, :user => Factory(:user)).should be_cool
FactoryGirl(:user).should do_some_stuff_with(:things)
```

To me, the thing that draws my attention in that code snippet is `FactoryGirl`. 
I don't care about `Factory`, I care about the actual models!  I prefer:

```ruby
User.gen.should be_valid
Name.gen( :string => 'something' ).should be_awesome
Comment.gen( :user => User.gen ).should be_cool
User.gen.should do_some_stuff_with(:things)
```

When you syntax highlight the above code, the constants (model names) are usually 
the things that really jump out at you.  Even in plain text, it's easier to 
understand that code than the above `FactoryGirl(:code)` in my opinion.

## License

factory_girl_extensions is released under the MIT license.
