require "factory_girl_extensions/version"

module FactoryGirl
  module Syntax

    # Extends any object to provide generation methods for factories.
    #
    # Usage:
    #
    #   require 'factory_girl_extensions'
    #
    #   ...
    #
    module ObjectMethods
      
      def build(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Build, overrides)
        yield(instance) if block_given?
        instance
      end
      
      def generate(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Build, overrides, &block)
        instance.save
        instance
      end

      def generate!(*args, &block)
        factory, overrides = ObjectMethods.factory_and_overrides(name.underscore, args)
        instance = factory.run(Strategy::Build, overrides, &block)
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
