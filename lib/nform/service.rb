require 'nform/core_ext'

module NForm
  # Services expect valid input
  # A service performs a single action
  # A service should not accept unfiltered user input,
  # but accept a form object when user input is required
  class Service
    include Hashable

    attr_reader :form
    def initialize(input)
      @form = get_form(input)
    end

    def call
      raise "Must be defined in subclass"
    end

    def self.call(*args)
      new(*args).call
    end

    def self.form_class(klass=nil)
      @@form_class = klass || const_get(:Form)
    end

    def self.form_object &block
      form = Class.new(Form)
      form.class_eval &block
      const_set :Form, form
    end

    private
    def get_form(input)
      input.is_a?(@@form_class) ? input : @@form_class.new(input)
    end

    def error!(message)
      raise ServiceError.new(message)
    end

    def validate!
    end
  end

  class ServiceError < Error
    attr_reader :message
    def initialize(message="Unknown Error")
      @message = message
    end
  end
end
