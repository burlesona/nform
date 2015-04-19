require 'active_support/core_ext/hash'
require 'nform/coercions'

# Step 1 Refactoring
# Simplify attribute set to be a hash of options rather than different sets of options
# COMPLETE

# Step 2 Refactoring
# Use new Coercions rather than reading methods from the including object
# COMPLETE

# Step 3 Refactoring
# Allow coercions to be passed as an array that will be called in a chain
# eg. `coerce: [:string,:trim,:presence] etc.
# Have to come up with a desired behavior for if the chain fails...


module NForm
  module Attributes
    def attribute(name,coerce:nil,required:false,default:nil)
      attribute_set[name.to_sym] = {coerce: coerce, required: required, default: default}
    end

    def attribute_set
      @attribute_set ||= {}
    end

    def undefined_attributes(option)
      unless %i|raise ignore|.include?(option)
        raise ArgumentError, "Unknown option `#{option}` for undefined attributes. Options are :raise or :ignore"
      end
      @undef_attr = option
    end

    def __undef_attr
      @undef_attr ||= :raise
    end

    def define_attributes
      attribute_set.each do |name,options|
        define_method(name) do
          instance_variable_get("@#{name}")
        end

        # TODO: must use coercion set
        c = get_coercion(options[:coerce])
        define_method("#{name}=") do |input|
          instance_variable_set("@#{name}", c.call(input))
        end
      end
    end

    def get_coercion(coerce_option)
      case
      when coerce_option.nil?
        proc{|n| n }
      when coerce_option.is_a?(Symbol)
        NForm::Coercions.fetch(coerce_option)
      when coerce_option.respond_to?(:call)
        coerce_option
      when coerce_option.is_a?(Enumerable)
        chain = coerce_option.map{|o| get_coercion(o) }
        proc do |input|
          chain.reduce(input){|i,c| c.call(i) }
        end
      else
        raise Error, "Invalid coerce option given"
      end
    end

    def self.extended(base)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def initialize(input={})
        i = input.symbolize_keys
        require_attributes!(i)
        self.class.define_attributes
        set_attributes!(i)
        set_missing_defaults
      end

      def to_hash
        self.class.attribute_set.each.with_object({}) do |(k,v),memo|
          memo[k] = send(k)
        end
      end

      private
      def require_attributes!(input_hash)
        required = self.class.attribute_set.map{|name,options| name if options[:required]}.compact
        missing  = (required - input_hash.keys)
        if missing.any?
          raise ArgumentError, "Missing required attributes: #{missing.inspect}"
        end
      end

      def set_attributes!(input_hash)
        input_hash.each do |k,v|
          if self.class.__undef_attr == :raise
            raise ArgumentError, "Undefined attribute: #{k}" unless respond_to?("#{k}=")
          end
          send "#{k}=", v if respond_to?("#{k}=")
        end
      end

      def set_missing_defaults
        self.class.attribute_set.each do |name, options|
          default = options[:default]
          unless default.nil?
            send("#{name}=",default) if send(name).nil?
          end
        end
      end
    end
  end
end

