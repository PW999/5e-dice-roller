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
    raise EvalPreventionError unless (rolled_string =~ /[a-zA-Z_:,%\u0040-\uFFFF]/).nil?

    evaluation_roll = eval(rolled_string)
    @logger.info("#{@text_roll} => #{evaluation_roll}")
    evaluation_roll
  end

  private

  def replace_rolls(text_roll)
    rolled_string = text_roll.dup        # the string should be non-frozen
    die = rolled_string[/\d+D\d+/]
    until die.nil?
      parts = die.split 'D'
      roll = Roll.new parts[0].to_i, parts[1].to_i, nil
      rolled_string[die] = roll.execute.to_s
      @logger.debug("#{die} rolled; #{text_roll} => #{rolled_string}")
      die = rolled_string[/\d+D\d+/]
    end
    rolled_string
  end
end

class MismatchedBracesError < StandardError
end

class EvalPreventionError < StandardError
end
