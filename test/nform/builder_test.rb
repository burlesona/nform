require 'test_helper'

# Next Up:
# - {year:,month:,day:} -> Date
# - Date -> hash
# - Date Inputs
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
      out = %Q|<form id="builder-tester" action="/builder-testers/1" method="POST">\n| +
            %Q|<input type="hidden" name="_method" value="PATCH">\n| +
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

    it "should override action" do
      out = %Q|<form id="builder-tester" action="/tests" method="POST"></form>|
      assert_equal out, form_view(BuilderTester.new, action: "/tests")
    end

    it "should override method" do
      out = %Q|<form id="builder-tester" action="/builder-testers/1" method="POST">\n| +
            %Q|<input type="hidden" name="_method" value="PUT">\n| +
            %Q|</form>|
      assert_equal out, form_view(BuilderTester.new(false), method: "PUT")
    end

    it "should accept a symbol instead of an object" do
      out = %Q|<form id="test" action="/tests" method="POST"></form>|
      assert_equal out, form_view(:test)
    end

    it "should override object name if object responds to model" do
      ExampleObject = Class.new(BuilderTester) do
        def model
          "Amazing::Foo"
        end
      end
      out = %Q|<form id="foo" action="/foos" method="POST">\n|+
            %Q|<label for="a-thing">A Thing</label>\n|+
            %Q|<input type="text" id="a-thing" name="foo[a_thing]" value="foobar">\n|+
            %Q|</form>|
      assert_equal out, form_view(ExampleObject.new){|f| f.text_field(:a_thing) }
    end
  end

  describe "inputs" do
    before do
      @form = NForm::Builder.new( BuilderTester.new )
    end

    it "should make a title" do
      assert_equal "Create Builder Tester", @form.title
    end

    it "should make a submit button" do
      assert_equal "<button>Create</button>", @form.submit_button
    end

    it "should make a text_field" do
      out = %Q|<label for="a-thing">A Thing</label>\n| +
            %Q|<input type="text" id="a-thing" name="builder_tester[a_thing]" value="foobar">|
      assert_equal out, @form.text_field(:a_thing)
    end

    it "should make a text_field with default value" do
      out = %Q|<label for="a-nil">A Nil</label>\n| +
            %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]" value="testery">|
      assert_equal out, @form.text_field(:a_nil, default: "testery")
    end

    it "should make a text_field with custom label" do
      out = %Q|<label for="a-nil">Fooness</label>\n| +
            %Q|<input type="text" id="a-nil" name="builder_tester[a_nil]">|
      assert_equal out, @form.text_field(:a_nil, label: "Fooness")
    end

    it "should make a hidden_field" do
      out = %Q|<input type="hidden" id="a-thing" name="builder_tester[a_thing]" value="foobar">|
      assert_equal out, @form.hidden_field(:a_thing)
    end

    it "should make a text_area" do
      out = %Q|<label for="a-thing">A Thing</label>\n|+
            %Q|<textarea id="a-thing" name="builder_tester[a_thing]">\n|+
            %Q|foobar\n|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_thing)
    end

    it "should make a text_area with default value" do
      out = %Q|<label for="a-nil">A Nil</label>\n|+
            %Q|<textarea id="a-nil" name="builder_tester[a_nil]">\n|+
            %Q|Foo!\n|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_nil, default: "Foo!")
    end

    it "should make a text_area with custom label" do
      out = %Q|<label for="a-nil">Foo</label>\n|+
            %Q|<textarea id="a-nil" name="builder_tester[a_nil]">|+
            %Q|</textarea>|
      assert_equal out, @form.text_area(:a_nil, label: "Foo")
    end

    it "should make a select field with options array" do
      options = %w|one two three|
      out = %Q|<label for="a-thing">A Thing</label>\n|+
            %Q|<select id="a-thing" name="builder_tester[a_thing]">\n|+
            %Q|<option value="one">one</option>\n|+
            %Q|<option value="two">two</option>\n|+
            %Q|<option value="three">three</option>\n|+
            %Q|</select>|
      assert_equal out, @form.select(:a_thing, options: options)
    end

    it "should make a select field with options hash" do
      options = {12 => "Acme Lawncare", 28 => "Foo Pest & Lawn"}
      out = %Q|<label for="a-thing">A Thing</label>\n|+
            %Q|<select id="a-thing" name="builder_tester[a_thing]">\n|+
            %Q|<option value="12">Acme Lawncare</option>\n|+
            %Q|<option value="28">Foo Pest & Lawn</option>\n|+
            %Q|</select>|
      assert_equal out, @form.select(:a_thing, options: options)
    end

    it "should make a select field with custom label" do
      options = {12 => "Acme Lawncare", 28 => "Foo Pest & Lawn"}
      out = %Q|<label for="a-thing">My Thing</label>\n|+
            %Q|<select id="a-thing" name="builder_tester[a_thing]">\n|+
            %Q|<option value="12">Acme Lawncare</option>\n|+
            %Q|<option value="28">Foo Pest & Lawn</option>\n|+
            %Q|</select>|
      assert_equal out, @form.select(:a_thing, options: options, label: "My Thing")
    end

    it "should make an association select" do
      Sample = Class.new do
        def self.all
          [OpenStruct.new(id: 1, name: "Tester")]
        end
        def self.first
          self.new
        end
        def self.map &block
          self.all.map &block
        end
      end
      out = %Q|<label for="sample-id">Sample</label>\n|+
            %Q|<select id="sample-id" name="builder_tester[sample_id]">\n|+
            %Q|<option value="1">Tester</option>\n|+
            %Q|</select>|
      assert_equal out, @form.association_select(Sample)
    end

    describe "date inputs" do
      it "should make a date input group" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Date</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date][month]" placeholder="MM" min="1" max="12" step="1" value="12">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date][day]" placeholder="DD" min="1" max="31" step="1" value="25">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date][year]" placeholder="YYYY" min="2015" max="2035" step="1" value="2014">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date)
      end

      it "should make a date input group with custom start and end year" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Date</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date][month]" placeholder="MM" min="1" max="12" step="1" value="12">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date][day]" placeholder="DD" min="1" max="31" step="1" value="25">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date][year]" placeholder="YYYY" min="1990" max="2020" step="1" value="2014">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date, start_year: 1990, end_year: 2020)
      end

      it "should omit value when value is nil" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Nil</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_nil][month]" placeholder="MM" min="1" max="12" step="1">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_nil][day]" placeholder="DD" min="1" max="31" step="1">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_nil][year]" placeholder="YYYY" min="2015" max="2035" step="1">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_nil)
      end

      it "should make a date input from a date hash" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Date Hash</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_date_hash][month]" placeholder="MM" min="1" max="12" step="1" value="12">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_date_hash][day]" placeholder="DD" min="1" max="31" step="1" value="25">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_date_hash][year]" placeholder="YYYY" min="2015" max="2035" step="1" value="2014">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_date_hash)
      end

      it "should make a date input from an empty hash" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Hash</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_hash][month]" placeholder="MM" min="1" max="12" step="1">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_hash][day]" placeholder="DD" min="1" max="31" step="1">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_hash][year]" placeholder="YYYY" min="2015" max="2035" step="1">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_hash)
      end

      it "should make a date input with default values" do
        out = %Q|<div class="date-input">\n|+
              %Q|<label>A Hash</label>\n|+
              %Q|<input class="date-month" type="number" name="builder_tester[a_hash][month]" placeholder="MM" min="1" max="12" step="1" value="1">\n|+
              %Q|<input class="date-day" type="number" name="builder_tester[a_hash][day]" placeholder="DD" min="1" max="31" step="1" value="1">\n|+
              %Q|<input class="date-year" type="number" name="builder_tester[a_hash][year]" placeholder="YYYY" min="2015" max="2035" step="1" value="2015">\n|+
              %Q|</div>|
        assert_equal out, @form.date_input(:a_hash, default:{day:1,month:1,year:2015})
      end
    end
  end
end
