require 'test_helper'

describe NForm::Attributes do
  class Example
    extend NForm::Attributes
    attribute :sample
    attribute :a_date, coerce: :input_to_date
    attribute :a_string, coerce: proc{|s| s.upcase }

    private
    def input_to_date(input)
      if input.nil?
        nil
      elsif input.is_a?(Date)
        input
      elsif input.is_a?(Hash)
        Date.new(input[:year],input[:month],input[:day])
      end
    end
  end

  it "should work with nil input" do
    a = Example.new
    assert_equal nil, a.sample
    assert_equal nil, a.a_date
    assert_equal nil, a.a_string
  end

  it "should noop without coercion" do
    a = Example.new(sample: 1)
    assert_equal 1, a.sample
    a = Example.new(sample: "abc")
    assert_equal "abc", a.sample
  end

  it "should parse on coercion" do
    a = Example.new(a_date:{year:2015,month:1,day:1})
    assert a.a_date.is_a?(Date)
  end

  it "should return a hash of coerced values" do
    out = {sample: "Hello", a_date: Date.new(2015,1,1), a_string: nil}
    a = Example.new sample: "Hello", a_date: {year:2015,month:1,day:1}
    assert_equal out, a.to_hash
  end

  it "should call proc to coerce" do
    a = Example.new a_string: "hello"
    assert_equal "HELLO", a.a_string
  end
end
