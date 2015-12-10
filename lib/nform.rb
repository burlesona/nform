module NForm
  # A base error class for any NForm exceptions to extend
  Error = Class.new(StandardError)
end

# Food for thought:
# Not all this code is really required,
# the library could be configured to not require all
# and let the user just require the bits they want instead...
# In that case, this list should be used as the basis for
# `require nform/all`
# For now, continuing to load all.
require 'nform/helpers'
require 'nform/html'
require 'nform/builder'
require 'nform/attributes'
require 'nform/validations'
require 'nform/coercions'
require 'nform/form'
require 'nform/service'
