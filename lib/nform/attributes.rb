module NForm
  module Attributes
    def attribute(name,coerce:nil)
      attribute_set[name] = define_coercion(coerce)
    end

    def attribute_set
      @attribute_set ||= {}
    end

    def define_attributes
      attribute_set.each do |a,c|
        define_method(a) do
          instance_variable_get("@#{a}")
        end
        define_method("#{a}=") do |i|
          instance_variable_set("@#{a}",c.call(i,self))
        end
      end
    end

    def define_coercion(defn)
      case
      when defn.nil? then proc{|val,scope| val }
      when defn.is_a?(Symbol) then proc{|val,scope| scope.method(defn).call(val)}
      when defn.respond_to?(:call) then defn
      else raise "Invalid Coercion method given"
      end
    end

    def self.extended(base)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def initialize(input={})
        self.class.define_attributes
        input.each do |k,v|
          send "#{k}=",v
        end
      end

      def to_hash
        self.class.attribute_set.each.with_object({}) do |(k,v),memo|
          memo[k] = send(k)
        end
      end
    end
  end
end

