module NForm
  module Attributes
    def attribute(name,coerce:nil,required:false,default:nil)
      attribute_set[name] = define_coercion(coerce)
      required_attributes << name if required
      default_attributes[name] = default if default
    end

    def attribute_set
      @attribute_set ||= {}
    end

    def required_attributes
      @required_attributes ||= []
    end

    def default_attributes
      @default_attributes ||= {}
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
      def initialize(**input)
        require_attributes!(input)
        self.class.define_attributes
        input.each do |k,v|
          send "#{k}=",v
        end
        set_missing_defaults
      end

      def to_hash
        self.class.attribute_set.each.with_object({}) do |(k,v),memo|
          memo[k] = send(k)
        end
      end

      private
      def require_attributes!(attrs)
        missing = (self.class.required_attributes - attrs.keys)
        if missing.any?
          raise ArgumentError, "Missing required attributes: #{missing.inspect}"
        end
      end

      def set_missing_defaults
        self.class.attribute_set.keys.each do |a|
          if send(a).nil? && d = self.class.default_attributes[a]
            send "#{a}=", d
          end
        end
      end
    end
  end
end

