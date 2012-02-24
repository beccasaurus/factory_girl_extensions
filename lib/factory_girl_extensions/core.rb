require "factory_girl_extensions/version"

module FactoryGirl
  module Syntax

    # Extends any object to provide generation methods for factories.
    #
    # Usage:
    #
    #   require 'factory_girl_extensions'
    #
    #   FactoryGirl.define do
    #     factory :admin_user, :class => User do
    #       name 'Billy Bob'
    #       is_admin true
    #     end
    #
    #     factory :user_with_profile, :class => User do
    #       name 'Admin Bob'
    #       profile_complete true
    #     end
    #
    #     factory :admin_user_with_profile, :class => User do
    #       name 'Admin Bob'
    #       is_admin true
    #       profile_complete true
    #     end
    #   end
    #   
    #   # Creates a saved instance without raising (same as saving the result
    #   # of FactoryGirl.build)
    #   User.generate(:name => 'Johnny')
    #   
    #   # Creates a saved instance and raises when invalid (same as
    #   # FactoryGirl.create)
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
    #   # Generates and returns a Hash of attributes from this factory 
    #   # (same as FactoryGirl.attributes_for).
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
      
      def build(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Build, overrides, &block)
        instance
      end
      
      def generate(*args, &block)
        instance = build(*args, &block)
        instance.save
        instance
      end

      def generate!(*args, &block)
        instance = build(*args, &block)
        instance.save!
        instance
      end

      def attributes(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        attrs = factory.run(Strategy::AttributesFor, overrides, &block)
        attrs
      end

      alias attrs attributes
      alias gen   generate
      alias gen!  generate!

      # @private
      def self.factory_and_overrides(base_name, args)
        overrides = args.last.is_a?(Hash) ? args.pop : {}
        factory   = find_factory(base_name, args)

        [factory, overrides]
      end

      # @private
      def self.find_factory(base_name, prefix_and_suffix)
        case prefix_and_suffix.length
        when 0
          FactoryGirl.factory_by_name(base_name)
        when 1
          begin
            FactoryGirl.factory_by_name([prefix_and_suffix.first, base_name].join("_"))
          rescue ArgumentError => ex
            raise ex unless ex.message =~ /Factory not registered/
            FactoryGirl.factory_by_name([base_name, prefix_and_suffix.first].join("_"))
          end
        when 2
          FactoryGirl.factory_by_name([prefix_and_suffix.first, base_name, prefix_and_suffix.last].join("_"))
        else
          raise ArgumentError.new("Don't know how to find factory for #{base_name.inspect} with #{prefix_and_suffix.inspect}")
        end
      end
    end
  end
end
