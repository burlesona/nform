require 'test_helper'

describe NForm::Validations do
  class Example
    include NForm::Validations

    def something; "foo"; end
    def an_int; 1; end
    def a_float; 1.0; end
    def int_string; "1"; end
    def float_string; "1.0"; end
    def non_number; :foo; end
    def long_string; "123456"; end
    def short_string; "123"; end
    def confirm; "abc"; end
    def confirm_confirmation; "abc"; end
    def wrongconfirm; "hello"; end
    def wrongconfirm_confirmation; "goodbye"; end
    def noconfirm; 1; end

  end
  ex = Example.new

  describe "presence" do
    it "should pass for defined attribute" do
      assert_equal true, ex.validate_presence_of(:something)
    end

    it "should fail for undefined attribute" do
      assert_equal false, ex.validate_presence_of(:nothing)
      assert ex.errors[:nothing]
    end
  end

  describe "numericality" do
    it "should pass for int" do
      assert_equal true, ex.validate_numericality_of(:an_int)
    end
    it "should pass for float" do
      assert_equal true, ex.validate_numericality_of(:a_float)
    end
    it "should pass for anything that can to_i" do
      assert_equal true, ex.validate_numericality_of(:int_string)
    end
    it "should pass for anything that can to_f" do
      assert_equal true, ex.validate_numericality_of(:float_string)
    end
    it "should fail for non-number" do
      assert_equal false, ex.validate_numericality_of(:non_number)
      assert ex.errors[:non_number]
    end
  end

  describe "length" do
    it "should pass for anything long enough" do
      assert_equal true, ex.validate_length_of(:long_string,6)
    end
    it "should fail for anything too short" do
      assert_equal false, ex.validate_length_of(:short_string,6)
      assert ex.errors[:short_string]
    end
  end

  describe "confirmation" do
    it "should pass for an attribute with matching _confirmation" do
      assert_equal true, ex.validate_confirmation_of(:confirm)
    end
    it "should fail for anything with no matching _confirmation" do
      assert_equal false, ex.validate_confirmation_of(:wrongconfirm)
      assert ex.errors[:wrongconfirm_confirmation]
    end
    it "should fail for anything with no _confirmation method" do
      assert_equal false, ex.validate_confirmation_of(:noconfirm)
      assert ex.errors[:noconfirm]
    end
  end
end
