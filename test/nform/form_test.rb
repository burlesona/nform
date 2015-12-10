require 'test_helper'

class FormTest < NForm::Form
  attribute :alpha, coerce: :to_integer, required: true
  attribute :beta, coerce: :to_string, required: true
  attribute :charlie

  def validate!
    validate_presence_of :alpha, :beta
    errors[:alpha] = "Alpha must be greater than 10" unless alpha > 10
    super
  end
end

describe NForm::Form do
  it "should init with required args" do
    f = FormTest.new(alpha: 11, beta: "hello")
    assert_equal true, f.valid?
  end

  it "should raise argument error without required args" do
    assert_raises(ArgumentError) do
      FormTest.new
    end
  end

  it "should validate args" do
    f = FormTest.new(alpha: 5, beta: "hello")
    assert_equal false, f.valid?
    assert_equal "Alpha must be greater than 10", f.errors[:alpha]
  end
end
