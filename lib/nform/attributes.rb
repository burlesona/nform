require 'active_support/core_ext/hash'
require 'nform/coercions'
require 'set'

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

    def hash_representation(option)
      unless %i|partial complete|.include?(option)
        raise ArgumentError, "Unknown option `#{option}` for hash representation. Options are :partial or :complete"
      end
      @hash_rep = option
    end

    def __undef_attr
      @undef_attr ||= :raise
    end

    def __hash_rep
      @hash_rep ||= :complete
    end

    def define_attributes
      attribute_set.each do |name,options|
        define_method(name) do
          instance_variable_get("@#{name}")
        end

        # TODO: must use coercion set
        c = get_coercion(options[:coerce])
        define_method("#{name}=") do |input|
          @__touched_keys << name
          instance_variable_set("@#{name}", c.call(input,self))
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
        proc do |input,scope|
          chain.reduce(input){|i,c| c.call(i,scope) }
        end
      else
        raise Error, "Invalid coerce option given"
      end
    end

    def self.extended(base)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def initialize(input=nil)
        input ||= {}
        @__touched_keys = Set.new
        i = input.symbolize_keys
        require_attributes!(i)
        self.class.define_attributes
        set_attributes!(i)
      end

      def to_hash
        if self.class.__hash_rep == :partial
          @__touched_keys
        else
          self.class.attribute_set.keys
        end.each.with_object({}) do |k,memo|
          memo[k] = send(k)
        end
      end

      private
      def require_attributes!(input_hash)
        # Check for missing required attributes
        required = self.class.attribute_set.map{|name,options| name if options[:required]}.compact
        missing  = (required - input_hash.keys)
        if missing.any?
          raise ArgumentError, "Missing required attributes: #{missing.inspect}"
        end

        # Check for unallowed extra attributes
        if self.class.__undef_attr == :raise
          extra = (input_hash.keys - self.class.attribute_set.keys)
          raise ArgumentError, "Undefined attribute(s): #{extra.join(',')}" if extra.any?
        end
      end

      def set_attributes!(input_hash)
        self.class.attribute_set.each do |a, opts|
          val = input_hash.fetch(a, opts[:default])
          send "#{a}=", val if input_hash.has_key?(a) || !opts[:default].nil?
        end
      end
    end
  end
end

