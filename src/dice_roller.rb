# frozen_string_literal: true

require_relative 'roll_parser'

puts 'Enter your roll:'
roll_input = gets.chomp
rolled_value = RollParser.new(roll_input).parse
puts "You rolled in total #{rolled_value}"