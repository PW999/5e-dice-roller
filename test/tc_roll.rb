# frozen_string_literal: true

require_relative '../src/roll'
require_relative '../src/log_config'
require 'test/unit'

class TestRoll < Test::Unit::TestCase
  def setup
    @logger = Logging.logger['Test::TestRoll']
  end

  def test_roll_one_d20
    roll = Roll.new(1, 20, nil)
    roll.replace_dice([MockDie.new(5)], nil)
    result = roll.execute
    assert_equal(result, 5, 'Expected single roll to be 5')
  end

  def test_roll_five_d20
    roll = Roll.new(5, 20, nil)
    roll.replace_dice([MockDie.new(3), MockDie.new(1), MockDie.new(1), MockDie.new(15), MockDie.new(10)], nil)
    result = roll.execute
    assert_equal(result, 30, 'Expected sum of [3, 1, 1, 15, 10] rolls to be 30')
  end

  def test_roll_one_d20_with_advantage_success
    roll = Roll.new(1, 20, true)
    roll.replace_dice([MockDie.new(3)], MockDie.new(10))
    result = roll.execute
    assert_equal(result, 10, 'Expected advantageous roll of 10 to be returned')
  end

  def test_roll_one_d20_with_advantage_fail
    roll = Roll.new(1, 20, true)
    roll.replace_dice([MockDie.new(10)], MockDie.new(3))
    result = roll.execute
    assert_equal(result, 10, 'Expected original, higher roll of 10 to be returned')
  end

  def test_roll_one_d20_with_disadvantage_success
    roll = Roll.new(1, 20, false)
    roll.replace_dice([MockDie.new(3)], MockDie.new(10))
    result = roll.execute
    assert_equal(result, 3, 'Expected disadvantageous roll of 3 to be returned')
  end

  def test_roll_one_d20_with_disadvantage_fail
    roll = Roll.new(1, 20, false)
    roll.replace_dice([MockDie.new(10)], MockDie.new(3))
    result = roll.execute
    assert_equal(result, 3, 'Expected original, lower roll of 3 to be returned')
  end

end

class MockDie
  def initialize(roll)
    @roll = roll
  end

  def roll
    @roll
  end
end
