# frozen_string_literal: true

require_relative 'log_config'
require_relative 'roll'

##
# This class will interpret the text input and convert it into rolls of dice
class RollParser
  def initialize(roll_input)
    @logger = Logging.logger[self]
    @text_roll = roll_input.chomp.upcase.gsub(' ', '')
    @rolls = []
  end

  def parse
    raise MismatchedBracesError unless @text_roll.count('(') == @text_roll.count(')')

    # eval is kind of evil so let's limit what it will take
    rolled_string = replace_rolls @text_roll
    unless (rolled_string =~ /[a-zA-Z_:,%\u0040-\uFFFF]/).nil?
      raise EvalPreventionError, "Unsafe to evaluate #{rolled_string}"
    end

    evaluation_roll = eval(rolled_string)
    @logger.info("#{@text_roll} => #{evaluation_roll}")
    evaluation_roll
  end

  private

  def replace_rolls(text_roll)
    rolled_string = text_roll.dup # the string should be non-frozen
    die_with_modifier = rolled_string[/(ADV|DIS)?(\(\d+D\d+\))|(\d+D\d+)/]
    until die_with_modifier.nil?
      rolled_value = roll_based_on_die_with_modifier(die_with_modifier)
      rolled_string[die_with_modifier] = rolled_value
      @logger.debug("#{die_with_modifier} rolled; #{text_roll} => #{rolled_string}")
      die_with_modifier = rolled_string[/(ADV|DIS)?(\(\d+D\d+\))|(\d+D\d+)/]
    end
    rolled_string
  end

  def roll_based_on_die_with_modifier(die_with_modifier)
    die = die_with_modifier[/\d+D\d+/]
    parts = die.split 'D'
    roll = Roll.new parts[0].to_i, parts[1].to_i, extract_modifier(die_with_modifier)
    roll.execute.to_s
  end

  def extract_modifier(die_with_modifier)
    return nil if die_with_modifier.index('DIS').nil? && die_with_modifier.index('ADV').nil?

    # string contains either dis or adv, so if adv returns nil, it should be dis which is false
    die_with_modifier.index('ADV').is_a? Numeric
  end
end

class MismatchedBracesError < StandardError
end

class EvalPreventionError < StandardError
end
