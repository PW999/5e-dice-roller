# frozen_string_literal: true

require_relative '../src/die'
require_relative '../src/log_config'
require 'test/unit'

class TestDie < Test::Unit::TestCase

  def setup
    @logger = Logging.logger['Test::TestDie']
  end

  def test_roll_d4
    generic_dice_test(4)
  end

  def test_roll_d6
    generic_dice_test(6)
  end

  def test_roll_d8
    generic_dice_test(8)
  end

  def test_roll_d10
    generic_dice_test(10)
  end

  def test_roll_d12
    generic_dice_test(12)
  end

  def test_roll_d20
    generic_dice_test(20)
  end

  def test_roll_d100
    generic_dice_test(100)
  end

  def test_invalid_number_of_sides
    @logger.debug('Test a die with an invalid amount of faces')
    assert_raise(ArgumentError) { Die.new(22) }
  end

  def test_negative_sides
    @logger.debug('Test a die with an negative amount of faces')
    assert_raise(ArgumentError) { Die.new(-1) }
  end

  def generic_dice_test(sides)
    (0..100).each do |i|
      @logger.debug("Roll number #{i} of a #{sides} sided die")
      roll = Die.new(sides).roll
      assert(roll <= sides, "Roll #{i}: The D#{sides} value should be less than or equal to #{sides} but was #{roll}")
      assert(roll >= 1, "Rolle #{i}: The D#{sides} value should be higher than or equal to 1 but was #{roll}")
    end
  end

end
