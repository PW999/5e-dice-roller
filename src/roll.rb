# frozen_string_literal: true

require_relative 'die'
require_relative 'log_config'

##
# Represent rolling a die with modifiers
#
class Roll
  def initialize(number_of_dice, sides, advantage)
    @logger = Logging.logger[self]
    @dice = Array.new(number_of_dice, Die.new(sides))
    @extra_die = nil
    @extra_die_advantage = nil
    @sides = sides
    @rolls = []
    return if advantage.nil?

    set_advantage if advantage
    set_disadvantage unless advantage
  end

  ##
  # Performs the roll of all dice, replacing rolls because of advantage or disadvantage if necessary
  def execute
    @dice.each do |die|
      @rolls.push(die.roll)
    end
    @logger.debug("Rolls are #{@rolls}")
    roll_extra_die
    @rolls.sum
  end

  private

  def roll_extra_die
    return if @extra_die.nil? 

    rolled_value = @extra_die.roll
    @logger.debug("Extra roll was #{rolled_value}")
    add_advantage(rolled_value) if @extra_die_advantage
    add_disadvantage(rolled_value) unless @extra_die_advantage
    @logger.debug("Rolls after (dis)advantage are #{@rolls}")
  end

  ##
  # Replaces the lowest roll if the extra roll is higher than the lowest roll
  def add_advantage(rolled_value)
    @rolls = @rolls.sort
    return if rolled_value < @rolls.at(0)

    @logger.debug('Extra roll was more advantageous than the lowest roll, thus replacing it because of advantage')
    @rolls.shift
    @rolls.push(rolled_value)
  end

  ##
  # Replaces the highest roll if the extra roll is lower than the highest roll
  def add_disadvantage(rolled_value)
    @rolls = @rolls.sort
    return if rolled_value > @rolls.at((@rolls.size - 1))

    @logger.debug('Extra roll was less advantageous than the higher roll, thus replacing it because of disadvantage')
    @rolls.pop
    @rolls.push(rolled_value)
  end

  def set_advantage
    if !@extra_die.nil?
      unless @extra_die_advantage   # if you already have disadvantage, then advantage cancels it out
        @extra_die = nil
        @extra_die_advantage = nil
      end
    else
      @extra_die = Die.new(@sides)
      @extra_die_advantage = true
    end
  end

  def set_disadvantage
    if @extra_die.nil?
      if @extra_die_advantage   # if you already have disadvantage, then advantage cancels it out
        @extra_die = nil
        @extra_die_advantage = nil
      end
    else
      @extra_die = Die.new(@sides)
      @extra_die_advantage = false
    end
  end

  def replace_dice(mock, extra_die)
    @dice = mock
    @extra_die = extra_die
  end
end
