# frozen_string_literal: true

require_relative 'log_config'

##
# Represents a single die
# +sides+:: defines how many sides the die should be (valid values are 4, 6, 8, 10, 12, 20, 100)
class Die
  VALID_NUMBER_OF_SIDES = [4, 6, 8, 10, 12, 20, 100]

  def initialize(sides)
    @logger = Logging.logger[self]
    @logger.debug("Initializing a #{sides} sided die")
    unless VALID_NUMBER_OF_SIDES.include? sides
      raise ArgumentError, "#{sides} is not valid number of sides on a die, only #{VALID_NUMBER_OF_SIDES} are valid"
    end

    @sides = sides
    @rng = Random.new
  end

  def roll
    @rng.rand(@sides - 1) + 1
  end
end
