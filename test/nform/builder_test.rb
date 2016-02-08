require 'test_helper'

describe NForm::Builder do
  describe "new objects" do
    before do
      @form = NForm::Builder.new( BuilderTester.new )
    end

    it "should render a basic form" do
      out = %Q|<form id="builder-tester" action="/builder-testers" method="POST"></form>|
      assert_equal out, @form.render
    end
  end

  describe "existing objects" do
    before do
      @form = NForm::Builder.new(
        BuilderTester.new(false)
      )
    end

    it "should set method to patch when new is false" do
      out = %Q|<form id="builder-tester" action="/builder-testers/1" method="POST">| +
            %Q|<input type="hidden" name="_method" value="PATCH">| +
            %Q|</form>|
      assert_equal out, @form.render
    end
  end

  describe "overrides" do
    # These cases provide a little more useful coverage of the form_view helper
    # than makes sense to include in its test
    include NForm::Helpers

    it "should override id" do
      out = %Q|<form id="test" action="/builder-testers" method="POST"></form>|
      assert_equal out, form_view(BuilderTester.new, id: "test")
    end

    it "should override class" do
      out = %Q|<form id="test" class="foo" action="/builder-testers" method="POST"></form>|
      assert_equal out, form_view(BuilderTester.new, id: "test", form_class: "foo")
    end

    it "should override action" do
      out = %Q|<form id="builder-tester" action="/tests" method="POST"></form>|
      assert_equal out, form_view(BuilderTester.new, action: "/tests")
    end

    it "should override method" do
      out = %Q|<form id="builder-tester" action="/builder-testers/1" method="POST">| +
            %Q|<input type="hidden" name="_method" value="PUT">| +
            %Q|</form>|
      assert_equal out, form_view(BuilderTester.new(false), method: "PUT")
    end

    it "should accept a symbol instead of an object" do
      out = %Q|<form id="test" action="/tests" method="POST"></form>|
      assert_equal out, form_view(:test)
    end

    it "should override object name if object responds to object name" do
      SomeFoodle = Class.new(BuilderTester) do
        def object_name
          "foodle"
        end
      end
      out = %Q|<form id="foodle" action="/foodles" method="POST">|+
            %Q|<label for="a-thing">A Thing</label>|+
            %Q|<input type="text" id="a-thing" name="foodle[a_thing]" value="foobar">|+
            %Q|</form>|
      assert_equal out, form_view(SomeFoodle.new){|f| f.text_field(:a_thing) }
    end

    it "should override object name if object responds to model" do
      SomeFoo = Class.new(BuilderTester) do
        def model
          "Amazing::Foo"
        end
      end
      out = %Q|<form id="foo" action="/foos" method="POST">|+
            %Q|<label for="a-thing">A Thing</label>|+
            %Q|<input type="text" id="a-thing" name="foo[a_thing]" value="foobar">|+
            %Q|</form>|
      assert_equal out, form_view(SomeFoo.new){|f| f.text_field(:a_thing) }
    end
  end

  describe "inputs" do
    before do
      @form = NForm::Builder.new( BuilderTester.new )
    end

    it "should make a title" do
      assert_equal "Create Builder Tester", @form.title
    end

    it "should make a text_field" do
      out = %Q|<label for="a-thing">A Thing</label>| +
            %Q|<input type="text" id="a-thing" name="builder_tester[a_thing]" value="foobar">|
      assert_equal out, @form.text_field(:a_thing)
    end

    it "should make a text_field with default value" do
      out = %Q|<label for="a-nil">A Nil</label>| +
            %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]" value="testery">|
      assert_equal out, @form.text_field(:a_nil, default: "testery")
    end

    it "should make a text_field with custom label" do
      out = %Q|<label for="a-nil">Fooness</label>| +
            %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]">|
      assert_equal out, @form.text_field(:a_nil, label: "Fooness")
    end

    it "should make a text_field with no label" do
      out = %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]">|
      assert_equal out, @form.text_field(:a_nil, label: false)
    end

    it "should make a text_field with merged arbitrary attributes" do
      out = %Q|<label for="a-nil">Fooness</label>| +
            %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]" xattr="fooness">|
      assert_equal out, @form.text_field(:a_nil, label: "Fooness", xattr: "fooness")
    end

    it "should make a number field" do
      out = %Q|<label for="a-thing">A Thing</label>| +
            %Q|<input type="number" id="a-thing" name="builder_tester[a_thing]" value="foobar" pattern="\\d*">|
      assert_equal out, @form.number_field(:a_thing)
    end

    it "should make a number field with a default value" do
      out = %Q|<label for="a-nil">A Nil</label>| +
            %Q|<input type="number" id="a-nil" name="builder_tester[a_nil]" value="a_nil" pattern="\\d*">|
      assert_equal out, @form.number_field(:a_nil,default: 'a_nil')
    end

    it "should make a number field with merged arbitrary attributes" do
      out = %Q|<label for="a-thing">A Thing</label>| +
            %Q|<input type="number" id="a-thing" name="builder_tester[a_thing]" value="foobar" pattern="\\d+" min="0">|
      assert_equal out, @form.number_field(:a_thing,default: 'default',pattern: '\d+',min: 0)
    end

    it "should make a password_field" do
      out = %Q|<label for="password">Password</label>| +
            %Q|<input type="password" id="password" name="builder_tester[password]">|
      assert_equal out, @form.password_field(:password)
    end

    it "should make a password_field with merged arbitrary attributes" do
      out = %Q|<label for="password">Password</label>| +
            %Q|<input type="password" id="password" name="builder_tester[password]" xattr="fooness">|
      assert_equal out, @form.password_field(:password,xattr: "fooness")
    end

    it "should make a hidden_field" do
      out = %Q|<input type="hidden" id="a-thing" name="builder_tester[a_thing]" value="foobar">|
      assert_equal out, @form.hidden_field(:a_thing)
    end

    it "should make a hidden_field with merged arbitrary attributes" do
      out = %Q|<input type="hidden" id="a-thing" name="builder_tester[a_thing]" value="foobar" xattr="fooness">|
      assert_equal out, @form.hidden_field(:a_thing,xattr: "fooness")
    end

    it "should make a text_area" do
      out = %Q|<label for="a-thing">A Thing</label>|+
            %Q|<textarea id="a-thing" name="builder_tester[a_thing]">|+
            %Q|foobar|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_thing)
    end

    it "should make a text_area with default value" do
      out = %Q|<label for="a-nil">A Nil</label>|+
            %Q|<textarea id="a-nil" name="builder_tester[a_nil]">|+
            %Q|Foo!|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_nil, default: "Foo!")
    end

    it "should make a text_area with custom label" do
      out = %Q|<label for="a-nil">Foo</label>|+
            %Q|<textarea id="a-nil" name="builder_tester[a_nil]">|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_nil, label: "Foo")
    end

    it "should make a text_area with merged arbitrary attributes" do
      out = %Q|<label for="a-thing">A Thing</label>|+
            %Q|<textarea id="a-thing" name="builder_tester[a_thing]" xattr="fooness">|+
            %Q|foobar|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_thing,xattr: "fooness")
    end

    it "should make a boolean checkbox" do
      out = %Q|<label for="a-nil">A Nil</label>|+
            %Q|<input type="hidden" name="builder_tester[a_nil]" value="false">|+
            %Q|<input type="checkbox" id="a-nil" name="builder_tester[a_nil]" value="true">|
      assert_equal out, @form.bool_field(:a_nil)
    end

    it "should make a boolean checkbox checked" do
      out = %Q|<label for="a-true">A True</label>|+
            %Q|<input type="hidden" name="builder_tester[a_true]" value="false">|+
            %Q|<input type="checkbox" id="a-true" name="builder_tester[a_true]" value="true" checked>|
      assert_equal out, @form.bool_field(:a_true)
    end

    it "should make a false checkbox not checked" do
      out = %Q|<label for="a-false">A False</label>|+
            %Q|<input type="hidden" name="builder_tester[a_false]" value="false">|+
            %Q|<input type="checkbox" id="a-false" name="builder_tester[a_false]" value="true">|
      assert_equal out, @form.bool_field(:a_false)
    end

    it "should make a false string checkbox not checked" do
      out = %Q|<label for="a-false-string">A False String</label>|+
            %Q|<input type="hidden" name="builder_tester[a_false_string]" value="false">|+
            %Q|<input type="checkbox" id="a-false-string" name="builder_tester[a_false_string]" value="true">|
      assert_equal out, @form.bool_field(:a_false_string)
    end

    it "should make any other string checkbox checked" do
      out = %Q|<label for="a-thing">A Thing</label>|+
            %Q|<input type="hidden" name="builder_tester[a_thing]" value="false">|+
            %Q|<input type="checkbox" id="a-thing" name="builder_tester[a_thing]" value="true" checked>|
      assert_equal out, @form.bool_field(:a_thing)
    end

    it "should make a boolean checkbox with merged arbitrary attributes" do
      out = %Q|<label for="a-nil">A Nil</label>|+
            %Q|<input type="hidden" name="builder_tester[a_nil]" value="false">|+
            %Q|<input type="checkbox" id="a-nil" name="builder_tester[a_nil]" value="true" xattr="fooness">|
      assert_equal out, @form.bool_field(:a_nil,xattr: "fooness")
    end

    describe "select fields" do
      it "should make a select field with options array" do
        options = %w|one two three|
        out = %Q|<label for="a-thing">A Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]">|+
              %Q|<option></option>|+
              %Q|<option value="one">one</option>|+
              %Q|<option value="two">two</option>|+
              %Q|<option value="three">three</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options)
      end

      it "should make a select field with options array and selected option" do
        options = %w|foo bar foobar|
        out = %Q|<label for="a-thing">A Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]">|+
              %Q|<option></option>|+
              %Q|<option value="foo">foo</option>|+
              %Q|<option value="bar">bar</option>|+
              %Q|<option value="foobar" selected>foobar</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options)
      end

      it "should make a select field with options array and no blank" do
        options = %w|foo bar foobar|
        out = %Q|<label for="a-thing">A Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]">|+
              %Q|<option value="foo">foo</option>|+
              %Q|<option value="bar">bar</option>|+
              %Q|<option value="foobar" selected>foobar</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options, blank: false)
      end

      it "should make a select field with options hash" do
        options = {12 => "Acme Lawncare", 28 => "Foo Pest & Lawn"}
        out = %Q|<label for="a-thing">A Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]">|+
              %Q|<option></option>|+
              %Q|<option value="12">Acme Lawncare</option>|+
              %Q|<option value="28">Foo Pest & Lawn</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options)
      end

      it "should make a select field with custom label" do
        options = {12 => "Acme Lawncare", 28 => "Foo Pest & Lawn"}
        out = %Q|<label for="a-thing">My Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]">|+
              %Q|<option></option>|+
              %Q|<option value="12">Acme Lawncare</option>|+
              %Q|<option value="28">Foo Pest & Lawn</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options, label: "My Thing")
      end

      it "should make a select field with merged arbitrary attributes" do
        options = {12 => "Acme Lawncare", 28 => "Foo Pest & Lawn"}
        out = %Q|<label for="a-thing">A Thing</label>|+
              %Q|<select id="a-thing" name="builder_tester[a_thing]" xattr="fooness">|+
              %Q|<option></option>|+
              %Q|<option value="12">Acme Lawncare</option>|+
              %Q|<option value="28">Foo Pest & Lawn</option>|+
              %Q|</select>|
        assert_equal out, @form.select(:a_thing, options: options, xattr: "fooness")
      end

      # Consolidated test runs so setup can be shared
      it "should make an association select with various options" do
        Sample = Class.new do
          def self.all
            [OpenStruct.new(id: 1, name: "Tester"),
             OpenStruct.new(id: 2, name: "Foobar")]
          end
          def self.first
            self.new
          end
          def self.map &block
            self.all.map &block
          end
        end
        out = %Q|<label for="sample-id">Sample</label>|+
              %Q|<select id="sample-id" name="builder_tester[sample_id]">|+
              %Q|<option></option>|+
              %Q|<option value="1" selected>Tester</option>|+
              %Q|<option value="2">Foobar</option>|+
              %Q|</select>|
        assert_equal out, @form.association_select(Sample), "default output is wrong"

        out2 = %Q|<label for="sample-id">Custom Label</label>|+
               %Q|<select id="sample-id" name="builder_tester[sample_id]">|+
               %Q|<option></option>|+
               %Q|<option value="1" selected>Tester</option>|+
               %Q|<option value="2">Foobar</option>|+
               %Q|</select>|
        assert_equal out2, @form.association_select(Sample, label: "Custom Label"), "custom label output is wrong"

        out3 = %Q|<select id="sample-id" name="builder_tester[sample_id]">|+
               %Q|<option></option>|+
               %Q|<option value="1" selected>Tester</option>|+
               %Q|<option value="2">Foobar</option>|+
               %Q|</select>|
        assert_equal out3, @form.association_select(Sample, label: false), "no label output is wrong"

      end

      it "should make an association select with CamelCase class name" do
        SomeThing = Class.new do
          def self.all
            [OpenStruct.new(id: 1, name: "Tester"),
             OpenStruct.new(id: 2, name: "Foobar")]
          end
          def self.first
            self.new
          end
          def self.map &block
            self.all.map &block
          end
        end
        out = %Q|<label for="some-thing-id">Some Thing</label>|+
              %Q|<select id="some-thing-id" name="builder_tester[some_thing_id]">|+
              %Q|<option></option>|+
              %Q|<option value="1" selected>Tester</option>|+
              %Q|<option value="2">Foobar</option>|+
              %Q|</select>|
        assert_equal out, @form.association_select(SomeThing)
      end
    end

    describe "date inputs" do
      start_year ||= Date.today.year
      end_year ||= start_year+20

      it "should make a date input group" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Date</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date][month]" placeholder="MM" min="1" max="12" step="1" value="12">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date][day]" placeholder="DD" min="1" max="31" step="1" value="25">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1" value="2014">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date)
      end

      it "should make a date input group with custom start and end year" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Date</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date][month]" placeholder="MM" min="1" max="12" step="1" value="12">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date][day]" placeholder="DD" min="1" max="31" step="1" value="25">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date][year]" placeholder="YYYY" min="1990" max="2020" step="1" value="2014">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date, start_year: 1990, end_year: 2020)
      end

      it "should omit value when value is nil" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Nil</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_nil][month]" placeholder="MM" min="1" max="12" step="1">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_nil][day]" placeholder="DD" min="1" max="31" step="1">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_nil][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_nil)
      end

      it "should make a date input from a date hash" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Date Hash</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date_hash][month]" placeholder="MM" min="1" max="12" step="1" value="12">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date_hash][day]" placeholder="DD" min="1" max="31" step="1" value="25">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date_hash][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1" value="2014">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date_hash)
      end

      it "should make a date input from an empty hash" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Hash</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_hash][month]" placeholder="MM" min="1" max="12" step="1">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_hash][day]" placeholder="DD" min="1" max="31" step="1">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_hash][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_hash)
      end

      it "should make a date input with default values" do
        out = %Q|<div class="date-input">|+
              %Q|<label>A Hash</label>|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_hash][month]" placeholder="MM" min="1" max="12" step="1" value="1">|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_hash][day]" placeholder="DD" min="1" max="31" step="1" value="1">|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_hash][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1" value="2015">|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_hash, default:{day:1,month:1,year:2015})
      end
    end

    it "should make a submit button" do
      assert_equal "<button>Create</button>", @form.submit_button
    end

    it "should make a submit button with custom text" do
      assert_equal "<button>HELLO</button>", @form.submit_button(text: "HELLO")
    end

    it "should make a submit button with merged arbitrary attributes" do
      assert_equal %Q|<button xattr="fooness">Create</button>|, @form.submit_button(xattr: "fooness")
    end

    it "should make a submit button that says Save for not new objects" do
      tester = BuilderTester.new(false)
      assert_equal false, tester.new?
      form = NForm::Builder.new(tester)
      assert_equal false, form.new_object?
      assert_equal "<button>Save</button>", form.submit_button
    end
  end

  describe "error handling" do
    class ErrorTester < BuilderTester
      def a_thing
        "foo!"
      end
      def errors
        {base: "A Test!", a_thing: "Big oopsie!", a_date: "Wrong date."}
      end
    end

    before do
      @form = NForm::Builder.new( ErrorTester.new )
    end

    it "should list base errors at the top of the form" do
      out = %Q|<form id="error-tester" action="/error-testers" method="POST">| +
            %Q|<ul class="base errors">| +
            %Q|<li>A Test!</li>| +
            %Q|</ul>| +
            %Q|</form>|
      assert_equal out, @form.render
    end
    it "should make a span.error with any error message matching the input key" do
      out = %Q|<label for="a-thing">A Thing</label>| +
            %Q|<input type="text" id="a-thing" name="error_tester[a_thing]" value="foo!">|+
            %Q|<span class="error">Big oopsie!</span>|
      assert_equal out, @form.text_field(:a_thing)
    end

    it "should show errors on text_area" do
      out = %Q|<label for="a-thing">A Thing</label>|+
            %Q|<textarea id="a-thing" name="error_tester[a_thing]">|+
            %Q|foo!|+
            %Q|</textarea>|+
            %Q|<span class="error">Big oopsie!</span>|
      assert_equal out, @form.text_area(:a_thing)
    end

    it "should show errors on select field" do
      options = %w|one two three|
      out = %Q|<label for="a-thing">A Thing</label>|+
            %Q|<select id="a-thing" name="error_tester[a_thing]">|+
            %Q|<option></option>|+
            %Q|<option value="one">one</option>|+
            %Q|<option value="two">two</option>|+
            %Q|<option value="three">three</option>|+
            %Q|</select>|+
            %Q|<span class="error">Big oopsie!</span>|
      assert_equal out, @form.select(:a_thing, options: options)
    end

    it "should show errors on a date input group" do
      start_year ||= Date.today.year
      end_year ||= start_year+20
      out = %Q|<div class="date-input">|+
            %Q|<label>A Date</label>|+
            %Q|<input class="date-month" type="number" name="error_tester[a_date][month]" placeholder="MM" min="1" max="12" step="1" value="12">|+
            %Q|<input class="date-day" type="number" name="error_tester[a_date][day]" placeholder="DD" min="1" max="31" step="1" value="25">|+
            %Q|<input class="date-year" type="number" name="error_tester[a_date][year]" placeholder="YYYY" min="#{start_year}" max="#{end_year}" step="1" value="2014">|+
            %Q|<span class="error">Wrong date.</span>|+
            %Q|</div>|
      assert_equal out, @form.date_input(:a_date)
    end
  end
end
