# frozen_string_literal: true

require_relative '../src/die'
require 'test/unit'

class TestDie < Test::Unit::TestCase

  def test_roll
    [0..10].each do |i|
      roll = Die.new(4).roll
      assert(roll <= 4, "The die value should be less than or equal to 4 but was #{roll}")
      assert(roll >= 1, "The die value should be higher than or equal to 1 but was #{roll}")
    end
  end
end
