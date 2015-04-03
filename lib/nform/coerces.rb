module NForm
  module Coerces

    module_function

    def to_bool
      proc { |v| !(v.nil? || v == false || v == 'false') }
    end

    def to_float
      proc { |v| v.to_f }
    end

    def to_integer
      proc { |v| v.to_i }
    end

    def to_string
      proc {|v| v.to_s.strip }
    end

    def to_symbol
      proc {|v| v.to_sym unless v.nil? }
    end

    def to_presence
      proc {|v| v.presence }
    end

    def to_number
      proc do |v|
        if v && v.is_a?(String)
          v.gsub(/,/,'').to_f
        else
          v
        end
      end
    end

    def to_non_zero_number
      proc do |v|
        if v.is_a?(String)
          r = v.gsub(/,/,'').to_f
          r if r > 0
        elsif v.is_a?(Numeric)
          v if v > 0
        else
          nil
        end
      end
    end

  end
end
