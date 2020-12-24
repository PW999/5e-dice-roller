# frozen_string_literal: true

require_relative 'log_config'

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

    parse_block(@text_roll)
  end

  private

  def parse_block(block)
    @logger.debug("Parsing #{block}")
  end

  def split(block)
    @logger.debug("Splitting #{block}")
    
  end

  def rolls
    @rolls
  end
end

class MismatchedBracesError < StandardError
end
