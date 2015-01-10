require 'test_helper'

class InflectionTester
  include NForm::Inflections
end

describe NForm::Inflections do
  def i
    InflectionTester.new
  end

  describe "dasherize" do
    it "should convert foo_bar -> foo_bar" do
      assert_equal "foo-bar", i.dasherize("foo_bar")
    end
  end

  describe "demodulize" do
    it "should convert Foo::Bar -> Bar" do
      assert_equal "Bar", i.demodulize("Foo::Bar")
    end

    it "should leave Foo -> Foo" do
      assert_equal "Foo", i.demodulize("Foo")
    end
  end

  describe "underscore" do
    it "should convert FooBar -> foo_bar" do
      assert_equal "foo_bar", i.underscore("FooBar")
    end

    it "should convert Foo::Bar -> foo/bar" do
      assert_equal "foo/bar", i.underscore("Foo::Bar")
    end
  end

  describe "pluralize" do
    it "should convert cat -> cats" do
      assert_equal "cats", i.pluralize("cat")
    end

    it "should leave cats -> cats" do
      assert_equal "cats", i.pluralize("cats")
    end
  end

  describe "humanize" do
    it "should convert foo-bar -> foo bar" do
      assert_equal "foo bar", i.humanize("foo-bar")
    end

    it "should convert foo_bar-baz -> foo bar baz" do
      assert_equal "foo bar baz", i.humanize("foo_bar-baz")
    end

    it "should remove trailing _id" do
      assert_equal "author", i.humanize("author_id")
    end
  end

  describe "titleize" do
    it "should humanize and capitalize every word in a string" do
      assert_equal "Hello World", i.titleize("hello-world")
    end
  end
end
