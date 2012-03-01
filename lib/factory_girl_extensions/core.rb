module FactoryGirl
  module Syntax

    # Extends any object to provide generation methods for factories.
    #
    # Usage:
    #
    #   require 'factory_girl_extensions'
    #
    #   FactoryGirl.define do
    #     factory :user do
    #       name 'Bob Smith'
    #     end
    #   end
    #   
    #   # Creates a saved instance without raising (same as saving the result of FactoryGirl.build)
    #   User.generate(:name => 'Johnny')
    #   
    #   # Creates a saved instance and raises when invalid (same as FactoryGirl.create)
    #   User.generate!
    #   
    #   # Creates an unsaved instance (same as FactoryGirl.build)
    #   User.build
    #   
    #   # Creates an instance and yields it to the passed block
    #   User.generate do |user|
    #     # ...do something with user...
    #   end
    #
    #   # Creates and returns a Hash of attributes from this factory (same as FactoryGirl.attributes_for).
    #   User.attributes
    #
    #   # A few short aliases are included for convenience.
    #   User.gen
    #   User.gen!
    #   User.attrs
    #
    #   # Factories with custom prefix/suffixes are also supported.
    #   FactoryGirl.define do
    #     factory :admin_user, :parent => :user do
    #       is_admin true
    #     end
    #
    #     factory :user_with_profile, :parent => :user do
    #       profile_complete true
    #     end
    #
    #     factory :admin_user_with_profile, :parent => :admin_user do
    #       profile_complete true
    #     end
    #   end
    #
    #   # Generates the :admin_user factory
    #   User.generate(:admin)
    #   User.generate(:admin, :name => 'Cool Admin')
    #
    #   # Generates the :user_with_profile factory
    #   User.generate(:with_profile)
    #
    #   # Generates the :admin_user_with_profile factory
    #   User.generate(:admin, :with_profile)
    #   User.generate(:admin, :with_profile, :name => 'Custom name')
    #
    #   # User.build and User.attributes also support these custom prefix/suffixes.
    #   
    # This syntax was derived from remi Taylor's factory_girl_extensions.
    module ObjectMethods
      
      # Creates an unsaved instance (same as FactoryGirl.build)
      def build(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Build, overrides, &block)
        instance
      end
      
      # Creates a saved instance without raising (same as saving the result of FactoryGirl.build)
      def generate(*args, &block)
        instance = build(*args)
        instance.save
        yield instance if block_given?
        instance
      end

      # Creates a saved instance and raises when invalid (same as FactoryGirl.create)
      def generate!(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Create, overrides, &block)
        instance
      end

      # Creates and returns a Hash of attributes from this factory (same as FactoryGirl.attributes_for)
      def attributes(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        attrs = factory.run(Strategy::AttributesFor, overrides, &block)
        attrs
      end

      alias attrs attributes
      alias gen   generate
      alias gen!  generate!

      # @private
      #
      # Helper to get the Factory object and overrides hash from the arguments passed to any ObjectMethods.
      def self.factory_and_overrides(base_name, args)
        overrides = args.last.is_a?(Hash) ? args.pop : {}
        factory   = find_factory(base_name, args)
        raise ArgumentError.new("Could not find factory for #{base_name.inspect} with #{args.inspect}") unless factory
        [factory, overrides]
      end

      # @private
      #
      # Given the base_name for a class's factory and 0-2 parts (prefix/suffixes), 
      # this finds the first matching factory that FactoryGirl has in its registry.
      def self.find_factory(base_name, parts)
        case parts.length
        when 0
          detect_factory base_name
        when 1
          detect_factory "#{parts.first}_#{base_name}", "#{base_name}_#{parts.first}"
        when 2
          detect_factory "#{parts.first}_#{base_name}_#{parts.last}", "#{parts.last}_#{base_name}_#{parts.first}"
        else
          raise ArgumentError.new("Don't know how to find factory for #{base_name.inspect} with #{parts.inspect}")
        end
      end

      # @private
      #
      # Given any number of arguments representing the possible names for a factory that you 
      # want to find, this iterates over the given names and returns the first FactoryGirl 
      # factory object that FactoryGirl returns (skipping unregistered factory names).
      def self.detect_factory(*possible_factory_names)
        factory = nil
        possible_factory_names.each do |factory_name|
          begin
            factory = FactoryGirl.factory_by_name(factory_name)
            break
          rescue ArgumentError => e
            raise e unless e.message =~ /Factory not registered/
            next
          end
        end
        factory
      end
    end
  end
end

# Alias FactoryGirl::Syntax::ObjectMethods (which is named to be conventional with the official FactoryGirl syntaxes) 
# to FactoryGirlExtensions so it's easy for users to manually extend custom classes without having to remember the 
# unintuitive name of the real module.  We'll deprecate FactoryGirlExtensions if we get this merged into FactoryGirl.
FactoryGirlExtensions = FactoryGirl::Syntax::ObjectMethods

require "factory_girl_extensions/version"
