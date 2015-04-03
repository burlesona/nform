require 'test_helper'

describe NForm::Coerces do

  include NForm::Coerces

  describe "to_bool" do
    it "should be false when falsey" do
      assert_equal false,to_bool.call(nil)
      assert_equal false,to_bool.call(false)
      assert_equal false,to_bool.call("false")
    end
    it "should be true when truthy" do
      assert_equal true,to_bool.call(true)
      assert_equal true,to_bool.call("true")
    end
  end

  describe "to_float" do
    it "should be a float when float like" do
      assert_equal 0.0,to_float.call(nil)
      assert_equal 0.0,to_float.call("")
      assert_equal 1.314,to_float.call("1.314")
    end
  end

  describe "to_integer" do
    it "should be a int when integer like" do
      assert_equal 0,to_float.call(nil)
      assert_equal 0,to_float.call("")
      assert_equal 7,to_float.call("7")
    end
  end

  describe "to_string" do
    it "should be a string when string like" do
      assert_equal "",to_string.call(nil)
      assert_equal "",to_string.call("")
      assert_equal "kenpachi",to_string.call("kenpachi")
    end
    it "should strip as a bonus" do
      assert_equal "",to_string.call(" ")
      assert_equal "kenpachi",to_string.call(" kenpachi ")
    end
  end

  describe "to_symbol" do
    it "should be a symbol when symbol like" do
      assert_equal nil,to_symbol.call(nil)
      assert_equal :"",to_symbol.call("")
      assert_equal :kenpachi,to_symbol.call("kenpachi")
    end
  end

  describe "to_presence" do
    it "should have presence" do
      assert_equal nil,to_presence.call(nil)
      assert_equal nil,to_presence.call("")
      assert_equal "kenpachi",to_presence.call("kenpachi")
    end
  end

  describe "to_number" do
    it "should become a floating number" do
      assert_equal nil,to_number.call(nil)
      assert_equal 0.0,to_number.call("")
      assert_equal 3000.0,to_number.call("3,000")
    end
  end

  describe "to_non_zero_number" do
    it "should become non zero" do
      assert_equal nil,to_non_zero_number.call(nil)
      assert_equal nil,to_non_zero_number.call("")
      assert_equal 3000.0,to_non_zero_number.call("3,000")
      assert_equal 5,to_non_zero_number.call(5)
      assert_equal nil,to_non_zero_number.call(-5)
    end
  end
end
