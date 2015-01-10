module NForm
  # A base error class for any NForm exceptions to extend
  class Error < StandardError
  end
end

require 'nform/helpers'
require 'nform/inflections'
require 'nform/html'
require 'nform/builder'
