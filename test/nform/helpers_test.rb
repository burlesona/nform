require 'test_helper'

describe NForm::Helpers do
  include NForm::Helpers
  it "should render a basic form" do
    out = %Q|<form id="builder-tester" action="/builder-testers" method="POST"></form>|
    assert_equal out, form_view(BuilderTester.new)
  end
end
