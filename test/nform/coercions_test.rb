require 'test_helper'

describe NForm::Coercions do

  let(:c){ NForm::Coercions }

  describe "coercion set behavior" do
    it "should add coercion via subscript" do
      c[:plus_two] = proc{|n| n.to_i + 2 }
      assert_equal 4, c[:plus_two].call(2)
    end

    it "should call via subscript or method" do
      c[:plus_two] = proc{|n| n.to_i + 2 }
      assert_equal c.plus_two(2), c[:plus_two].call(2)
    end

    it "should fetch a known coercion" do
      assert c.fetch(:to_presence).is_a?(Proc)
    end

    it "should raise nform error on unknown coercion" do
      assert_raises(NForm::Error) do
        c.fetch(:unknown)
      end
    end

  end

  describe "to_presence" do
    it "should return nil for empty things" do
      assert_equal nil, c.to_presence(nil)
      assert_equal nil, c.to_presence("")
      assert_equal "kenpachi", c.to_presence("kenpachi")
    end
  end

  describe "to_bool" do
    it "should be false when falsey" do
      assert_equal false, c.to_bool(nil)
      assert_equal false, c.to_bool(false)
      assert_equal false, c.to_bool("false")
    end
    it "should be true when truthy" do
      assert_equal true, c.to_bool(true)
      assert_equal true, c.to_bool("true")
    end
  end

  describe "to_float" do
    it "should be a float when float like" do
      assert_equal 0.0, c.to_float(nil)
      assert_equal 0.0, c.to_float("")
      assert_equal 1.314, c.to_float("1.314")
    end
  end

  describe "to_integer" do
    it "should be a int when integer like" do
      assert_equal 0, c.to_integer(nil)
      assert_equal 0, c.to_integer("")
      assert_equal 7, c.to_integer("7")
    end
  end

  describe "to_string" do
    it "should be a string when string like" do
      assert_equal "", c.to_string(nil)
      assert_equal "", c.to_string("")
      assert_equal "kenpachi",c.to_string("kenpachi")
    end
    it "should strip as a bonus" do
      assert_equal "", c.to_string(" ")
      assert_equal "kenpachi", c.to_string(" kenpachi ")
    end
  end

  describe "to_symbol" do
    it "should be a symbol when symbol like" do
      assert_equal nil, c.to_symbol(nil)
      assert_equal :"", c.to_symbol("")
      assert_equal :kenpachi, c.to_symbol("kenpachi")
    end
  end

  describe "to_number" do
    it "should become a floating number" do
      assert_equal nil, c.to_number(nil)
      assert_equal 0.0, c.to_number("")
      assert_equal 3000.0, c.to_number("3,000")
    end
  end
end
