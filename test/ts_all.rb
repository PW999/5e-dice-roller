Dir[File.join(__dir__, 'tc_*.rb')].sort.each { |file| require file }
