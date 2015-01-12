module NForm
  # A Module of simple validation methods.
  # Including objects are required to implement a simple API:
  # 1. Keys passed in to a validation must match instance method names
  # 2. Objects must provide an errors object which responds to []
  #
  # When called, validators will return true/false indicating whether
  # the validation passed or failed
  module Validations
    def errors
      @errors ||= {}
    end

    def validate_presence_of(*keys)
      pass = true
      keys.each do |key|
        unless respond_to?(key) && send(key) && send(key) != ""
          errors[key] = "#{key.to_s.humanize} is required"
          pass = false
        end
      end
      pass
    end

    def validate_numericality_of(*keys)
      pass = true
      keys.each do |key|
        val = send(key)
        return true if val.is_a?(Numeric)
        unless (val.respond_to?(:to_i) || val.respond_to?(:to_f)) &&
           (val == val.to_i.to_s || val == val.to_f.to_s)
          errors[key] = "#{key.to_s.humanize} must be a number"
          pass = false
        end
      end
      pass
    end

    def validate_length_of(key,length)
      val = send(key)
      if val && val.respond_to?(:length) && val.length >= length
        true
      else
        errors[key] = "#{key.to_s.humanize} must be at least #{length} characters long"
        false
      end
    end

    def validate_confirmation_of(attribute)
      confirm_key = attribute.to_s.concat("_confirmation").to_sym
      if !respond_to?(confirm_key)
        errors[attribute] = "#{attribute.to_s.humanize} requires confirmation"
        false
      elsif send(attribute) != send(confirm_key)
        errors[confirm_key] = "#{attribute.to_s.humanize} confirmation does not match"
        false
      else
        true
      end
    end
  end
end
