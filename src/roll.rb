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

  def set_advantage
    if !@extra_die.nil?
      if !@extra_die_advantage   #if you already have disadvantage, then advantage cancels it out# 
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
      if @extra_die_advantage   #if you already have disadvantage, then advantage cancels it out# 
        @extra_die = nil
        @extra_die_advantage = nil
      end
    else
      @extra_die = Die.new(@sides)
      @extra_die_advantage = false
    end
  end

  def execute
    @dice.each do |die|
      @rolls.push(die.roll)
    end
    @rolls = @rolls.sort
    @logger.debug("Rolls are #{@rolls}")
    roll_extra_die
    @rolls.sum
  end

  def roll_extra_die 
    if !@extra_die.nil? 
      extra_roll = @extra_die.roll
      @logger.debug("Extra roll was #{extra_roll}")
      if @extra_die_advantage
        if extra_roll > @rolls.at(0)
          @rolls.shift
          @rolls.push(extra_roll)
        end
      else
        if extra_roll < @rolls.at(@rolls.size() -1)
          @rolls.pop
          @rolls.push(extra_roll)
        end
      end
    end
    @logger.debug("Rolls after (dis)advantage are #{@rolls}")
  end

  def replace_dice(mock, extra_die)
    @dice = mock
    @extra_die = extra_die
  end
end
