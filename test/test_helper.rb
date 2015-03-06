require 'ostruct'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
Minitest::Reporters.use!

# Add Project Lib Dir to Load Path
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))

require 'nform'

# Mock Class for testing builder instances
class BuilderTester
  attr_accessor :is_new
  def initialize(is_new=true)
    @is_new = is_new
  end

  def id
    1
  end

  def a_nil
  end

  def a_true
    true
  end

  def a_false
    false
  end

  def a_false_string
    "false"
  end

  def a_thing
    "foobar"
  end

  def a_hash
    {}
  end

  def a_date
    Date.new(2014,12,25)
  end

  def a_date_hash
    {year: a_date.year, month: a_date.month, day: a_date.day}
  end

  def sample_id
    1
  end

  def some_thing_id
    1
  end

  def password
  end

  def new?
    @is_new
  end
end
