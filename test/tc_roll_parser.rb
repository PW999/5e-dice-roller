# frozen_string_literal: true

require_relative '../src/roll_parser'
require_relative '../src/log_config'
require 'test/unit'

##
# It's kind of hard to test this without mock injection (and hence using tools like MInitest or RSpec).
# So in some cases this test just rolls a lot of time to check if the roll stays withing the expected
# boundaries. It's far from ideal but it's something. Otherwise I have to redefined the class (which is
# also dirty) or start using factories.)
class TestRollParser < Test::Unit::TestCase
  def setup
    @logger = Logging.logger['Test::TestRollParser']
    @rolls = []
    @empty_parser = RollParser.new('')  # this is an "empty" parser which can be used to test private/singleton-like method
  end

  def test_mismatched_braces
    assert_raise(MismatchedBracesError) { RollParser.new('(the rest of the content(does not matter)').parse }
  end

  def test_eval_limits
    assert_raise(EvalPreventionError) { RollParser.new('Dir.delete(\'c:\\Windows\')').parse }
  end


  def test_replace_one_die
    rolled_output = @empty_parser.__send__ 'replace_rolls', '1D20'
    assert(rolled_output['D'].nil?, 'All dice should have been rolled')
    assert(!rolled_output[/(^[1-9])$|(1\d)|(20)/].nil?, 'The output should be a string between 1-20')
  end

  def test_replace_multiple_dice
    rolled_output = @empty_parser.__send__ 'replace_rolls', '1D6+1D6+1D4-1D8'
    assert(rolled_output['D'].nil?, 'All dice should have been rolled')
    assert(!rolled_output[/^[1-6]\+[1-6]\+[1-4]-[1-8]$/].nil?, 'The output should be a string matching [1-6]+[1-6]+[1-4]-[1-8]')
  end

  def test_replace_multiple_dice_with_braces
    rolled_output = @empty_parser.__send__ 'replace_rolls', '1D6+(1D6+1D4)-1D8'
    assert(rolled_output['D'].nil?, 'All dice should have been rolled')
    assert(!rolled_output[/^[1-6]\+\([1-6]\+[1-4]\)-[1-8]$/].nil?, 'The output should be a string matching [1-6]+([1-6]+[1-4])-[1-8]')
  end

  def test_roll_two_d4
    25.times do
      rolled_value = RollParser.new('1D4+1D4').parse
      assert rolled_value >= 2, "2D4 roll at least a 2, instead got #{rolled_value}"
      assert rolled_value <= 8, "2D4 can not roll more than 8, instead got #{rolled_value}"
    end
  end

  def test_roll_two_d4_advantage_disadvantage
    25.times do
      rolled_value = RollParser.new('adv(1D4)+dis(1D4)').parse
      assert rolled_value >= 2, "2D4 roll at least a 2, instead got #{rolled_value}"
      assert rolled_value <= 8, "2D4 can not roll more than 8, instead got #{rolled_value}"
    end
  end

  def test_complex_roll
    100.times do
      rolled_value = RollParser.new('1D10+2*(1D20)-(1D4+5)').parse
      assert rolled_value >= -6, "-6 is the lowest this roll can go but got #{rolled_value}"
      assert rolled_value <= 46, "46 is the highest possible roll but got #{rolled_value}"
    end
  end

  def test_complex_roll_advantage
    100.times do
      rolled_value = RollParser.new('adv(1D10)+2*(dis(1D20))-(1D4+5)').parse
      assert rolled_value >= -6, "-6 is the lowest this roll can go but got #{rolled_value}"
      assert rolled_value <= 46, "46 is the highest possible roll but got #{rolled_value}"
    end
  end

  def test_if_roll_is_not_same
    rolls = Hash.new(0)
    80.times do
      rolled_value = RollParser.new('1D20').parse
      rolls[rolled_value] += 1
    end
    rolls.each do |key, value|
      assert value >= 1, "Every rolled value of a D20 is expected when rolling it 80 times, but #{key} never fell"
    end
  end
end
