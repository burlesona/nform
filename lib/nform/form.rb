require 'nform/core_ext'

module NForm
  class Form
    extend NForm::Attributes
    include NForm::Validations

    def valid?
      errors.clear
      validate!
      true
    rescue ValidationError
      false
    end

    def validate!
      yield if block_given?
      validation_error! if errors.any?
    end

    private
    def validation_error!(hash={})
      errors.merge(hash)
      raise ValidationError.new(errors)
    end
  end

  class ValidationError < Error
    attr_reader :errors
    def initialize(errors={})
      @errors = errors
    end

    def message
      "\nPlease correct the following errors:\n#{error_messages}"
    end

    def error_messages
      if errors.any?
        errors.map{|k,v| "#{k.to_s.humanize}: #{v}"}.join("\n")
      end
    end
  end
end
