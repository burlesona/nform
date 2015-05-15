require 'test_helper'

describe NForm::Attributes do
  describe "basic cases" do
    NForm::Coercions[:input_to_date] = proc do |input|
      if input.nil?
        nil
      elsif input.is_a?(Date)
        input
      elsif input.is_a?(Hash)
        Date.new(input[:year],input[:month],input[:day])
      end
    end
    class Example
      extend NForm::Attributes
      attribute :sample
      attribute :a_date, coerce: :input_to_date
      attribute :a_string, coerce: proc{|s| s.upcase }
    end
    it "should work with nil input" do
      a = Example.new
      assert_equal nil, a.sample
      assert_equal nil, a.a_date
      assert_equal nil, a.a_string
    end

    it "should work with string attrs" do
      a = Example.new 'sample' => 'foo'
      assert_equal 'foo', a.sample
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

  describe "required attributes" do
    class Example2
      extend NForm::Attributes
      attribute :an_optional
      attribute :a_required, required: true
    end

    it "should allow nil for optional attributes" do
      example = Example2.new(a_required: "foo")
      assert example
      assert example.an_optional == nil
    end

    it "should not allow nil for required attributes" do
      err = assert_raises(ArgumentError) do
        Example2.new(an_optional: "foo")
      end
      assert_match /(missing|required)/, err.message
    end
  end

  describe "default values" do
    class Example3
      extend NForm::Attributes
      attribute :a_normal
      attribute :a_default, default: "foo"
      attribute :a_coerce, default: false, coerce: proc{|n| !(n.nil? || n == false || n == 'false')}
    end

    it "should have a default value" do
      example = Example3.new
      assert_equal "foo", example.a_default
    end

    it "should not have default unless set" do
      example = Example3.new
      assert_equal nil, example.a_normal
    end

    it "should initialize with defaults set in hash representation" do
      hash = Example3.new.to_hash
      assert_equal nil, hash[:a_normal]
      assert_equal "foo", hash[:a_default]
    end

    it "should use coercion with defaults" do
      example = Example3.new
      assert_equal false, example.a_coerce
    end
  end

  describe "coercion chaining" do
    NForm::Coercions[:strip] = proc{|s| s.strip }
    class ExampleChain
      extend NForm::Attributes
      attribute :chain_to_nil, coerce: [:to_string,:strip,:to_presence]
      attribute :chain_to_string, coerce: [:to_string,:strip]
    end

    it "should chain coercions" do
      example = ExampleChain.new
      example.chain_to_nil = " tester foo   "
      assert_equal "tester foo", example.chain_to_nil
    end

    it "should return nil for no value" do
      example = ExampleChain.new(chain_to_nil: nil)
      assert_equal nil, example.chain_to_nil
    end

    it "should return empty string for chain to string" do
      example = ExampleChain.new(chain_to_string: nil)
      assert_equal "", example.chain_to_string
    end

    # There are potential runtime errors here if a method like "strip" above
    # requires input of a particular type. This can be avoided by checking in
    # the coercion, but in that case it probably makes more sense to have a
    # larger variety of single coercions that define a whole process, rather than chaining.

  end

  describe "undefined attributes" do
    class DefOnly
      extend NForm::Attributes
      attribute :a_thing
    end
    class DefOnlyExplicit
      extend NForm::Attributes
      undefined_attributes :raise
      attribute :a_thing
    end
    class UndefOk
      extend NForm::Attributes
      undefined_attributes :ignore
      attribute :a_thing
    end

    it "should raise ArgumentError when unspecified attributes are given" do
      assert_raises(ArgumentError){ DefOnly.new(foo:1) }
    end

    it "should raise ArgumentError when unspecified attributes are given" do
      assert_raises(ArgumentError){ DefOnlyExplicit.new(foo:1) }
    end

    it "should ignore unspecified attributes when so configured" do
      ex = UndefOk.new(foo: 1)
      assert_equal nil, ex.a_thing
      assert_raises(NoMethodError) do
        ex.foo
      end
    end
  end

  describe "method attributes" do
    class MethodAttribute

      extend NForm::Attributes
      chainy = proc{|input,scope| scope.send(:my_chain,input) }
      attribute :testpub, coerce: proc{|input,scope| scope.send(:my_public,input) }
      attribute :testpri, coerce: proc{|input,scope| scope.send(:my_private,input) }
      attribute :testchain, coerce: [:to_float, chainy]

      def test_true; true; end
      def test_false; false; end

      def my_public(input)
        if test_true
          input.to_s + "!"
        else
          nil
        end
      end

      private
      def my_private(input)
        if test_false
          nil
        else
          input.to_s + "?"
        end
      end

      def my_chain(input)
        input.to_s + "%"
      end
    end

    it "should allow wrapping a public instance method in a proc" do
      m = MethodAttribute.new
      m.testpub = 1
      assert_equal "1!", m.testpub
      m2 = MethodAttribute.new(testpub: 1)
      assert_equal "1!", m2.testpub
    end

    it "should allow wrapping a private instance method in a proc" do
      m = MethodAttribute.new
      m.testpri = 1
      assert_equal "1?", m.testpri
      m2 = MethodAttribute.new(testpri: 1)
      assert_equal "1?", m2.testpri
    end

    it "should allow including a wrapped method in a chain" do
      m = MethodAttribute.new
      m.testchain = "2"
      assert_equal "2.0%", m.testchain
    end
  end
end
