require 'test_helper'

class HashableTester
  include NForm::Hashable

  def a
    1
  end

  def b
    2
  end
end

describe NForm::Hashable do
  it "should generate a hash from its own methods" do
    h = HashableTester.new
    assert_equal ({a:1,b:2}), h.hash_of(:a,:b)
  end
end
