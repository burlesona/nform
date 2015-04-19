require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

module NForm
  class CoercionSet
    def [](key)
      set[key.to_sym]
    end

    def []=(key,val)
      set[key.to_sym] = val
    end

    def fetch(key)
      if v = set[key]
        v
      else
        raise Error, "Undefined coercion: #{key}"
      end
    end

    def respond_to_missing?(name,*)
      set.has_key?(name.to_sym)
    end

    def method_missing(name,*args,&block)
      if set[name.to_sym]
        set[name.to_sym].call(*args,&block)
      else
        super
      end
    end

    private
    def set
      @set ||= {}
    end
  end

  Coercions = CoercionSet.new
  Coercions[:to_presence] = proc {|v| v.presence }
  Coercions[:to_bool]     = proc { |v| !(v.nil? || v == false || v == 'false') }
  Coercions[:to_float]    = proc { |v| v.to_f }
  Coercions[:to_integer]  = proc { |v| v.to_i }
  Coercions[:to_string]   = proc {|v| v.to_s.strip }
  Coercions[:to_symbol]   = proc {|v| v.to_sym unless v.nil? }
  Coercions[:to_number]   = proc do |v|
    if v && v.is_a?(String)
      v.gsub(/,/,'').to_f
    else
      v
    end
  end
end
