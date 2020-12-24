# frozen_string_literal: true

require_relative '../src/roll_parser'
require_relative '../src/log_config'
require 'test/unit'

class TestRollParser < Test::Unit::TestCase
  def setup
    @logger = Logging.logger['Test::TestRollParser']
    @rolls = []
    @empty_parser = RollParser.new('')  # this is an "empty" parser which can be used to test private/singleton-like method
  end

  def test_mismatched_braces
    assert_raise(MismatchedBracesError) { RollParser.new('(the rest of the content(does not matter)').parse }
  end

  def test_split_one_die
    result = @empty_parser.__send__('split', '1D20')
    assert_equal ['+1D20'], result, 'Expected to find simple array'
  end

  def test_split_two_blocks
    result = @empty_parser.__send__('split', '(1D20+2)+(1D6+1)')
    assert_equal ['+(1D20+2)', '+(1D6+1)'], result, 'Expected to find two items in array'
  end

  def test_split_one_level
    result = @empty_parser.__send__('split', '((1D20+2)+(1D6+1))-5')
    assert_equal [['+(1D20+2)', '+(1D6+1)'], '-5'], result, 'Expected to find two items in array'
  end

  def skip_test_parse_simple_d20
    parser = RollParser.new('1D20')
    parser.parse
    rolls = parser.__send__('rolls')
    assert_equal 1, rolls.size, 'Expected exactly one roll'
  end

end
