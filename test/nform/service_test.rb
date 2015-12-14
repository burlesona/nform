require 'test_helper'
require 'ostruct'

class ServiceTest < NForm::Service
  form_class OpenStruct

  def call
    validate!
  end

  private
  def validate!
    error! "'a' must be numeric" unless form.a.is_a?(Numeric)
    error! "'b' must be numeric" unless form.b.is_a?(Numeric)
  end
end

class EmbeddedFormTest < NForm::Service
  class Form < NForm::Form
    attribute :a, coerce: :to_integer, required: true
    attribute :b, coerce: :to_integer, required: true

    def validate!
      validate_numericality_of :a, :b
      super
    end
  end


  def call
    validate!
    form.a + form.b
  end

  private
  def validate!
    form.validate!
    super
  end
end

class ComposableFormTest < NForm::Service
  class Form < NForm::Form
    attribute :num, coerce: :to_integer
  end

  def call
    other = EmbeddedFormTest.call(a:1,b:1)
    form.num + other
  end
end

describe "using form_class" do
  it "should generate a service object instance" do
    s = ServiceTest.new(a: 1, b: 2)
    assert s.is_a?(ServiceTest)
  end

  it "should respond to call" do
    s = ServiceTest.new(a: 1, b: 2)
    assert_equal true, s.respond_to?(:call)
  end

  it "should generate instance and call in one step" do
    input = {a:1,b:2}
    s1 = ServiceTest.new(input)
    assert_equal s1.call, ServiceTest.call(input)
  end

  it "should raise service errors" do
    input = {a:'a',b:'b'}
    err = assert_raises(NForm::ServiceError) do
      ServiceTest.call(input)
    end
    assert_match /numeric/, err.message
  end
end

describe "using embedded form" do
  it "should generate a service object instance" do
    s = EmbeddedFormTest.new(a: 1, b: 2)
    assert s.is_a?(EmbeddedFormTest)
  end

  it "should respond to call" do
    s = EmbeddedFormTest.new(a: 1, b: 2)
    assert_equal true, s.respond_to?(:call)
  end

  it "should generate instance and call in one step" do
    input = {a:1,b:2}
    s1 = EmbeddedFormTest.new(input)
    assert_equal s1.call, EmbeddedFormTest.call(input)
  end

  it "should raise argument errors" do
    assert_raises(ArgumentError) do
      EmbeddedFormTest.call()
    end
  end
end

describe "composition" do
  it "should be possible to compose services and forms" do
    res = ComposableFormTest.call(num: 2)
    assert_equal 4, res
  end
end
