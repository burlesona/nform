require 'active_support'

module NForm
  module Hashable
    # A convenience method for making a hash with the
    # given methods on self as the keys and return for
    # the given methods as the values
    def hash_of(*keys)
      keys.each.with_object({}){|k,h| h[k] = send(k) }
    end
  end
end
