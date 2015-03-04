require 'test_helper'

class HTMLTester
  include NForm::HTML
end

describe NForm::HTML do
  def h
    HTMLTester.new
  end

  it "should generate html tags" do
    out = h.tag :p
    assert_equal "<p></p>", out
  end

  it "should generate html tags with attributes" do
    out = h.tag :p, :class => "awesome"
    assert_equal %Q|<p class="awesome"></p>|, out
  end

  it "should ignore nil attributes" do
    out = h.tag :p, id: nil
    assert_equal "<p></p>", out
  end

  it "should sub underscore symbol args to dashes" do
    out = h.tag :p, data_foo: "bar"
    assert_equal %Q|<p data-foo="bar"></p>|, out
  end

  it "should leave string args as-is" do
    out = h.tag :p, "someWierd_stuffs" => "foo"
    assert_equal %Q|<p someWierd_stuffs="foo"></p>|, out
  end

  it "should generate html tags with content" do
    out = h.tag(:p, id: "foo"){ "Hello" }
    assert_equal %Q|<p id="foo">Hello</p>|, out
  end

  it "should nest tags" do
    out = h.tag :p, :class=>"super" do
      h.tag(:span){"Hello!"}
    end
    assert_equal %Q|<p class="super"><span>Hello!</span></p>|, out
  end

  it "should not close self closing tags" do
    out = h.tag :img, src: "foo.jpg"
    assert_equal %Q|<img src="foo.jpg">|, out
  end

  it "should join items by newlines (handy)" do
    out = h.njoin("one","two",nil,"three")
    assert_equal "one\ntwo\nthree", out
  end

  it "should generate boolean attributes" do
    out = %Q|<option value="test" selected>Test</option>|
    assert_equal out, h.tag(:option,value:"test",selected:true){ "Test" }
  end

  it "should not leave whitespace on false boolean attributes" do
    out = %Q|<option value="test">Test</option>|
    assert_equal out, h.tag(:option,value:"test",selected:false){ "Test" }
  end
end
