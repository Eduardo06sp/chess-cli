# frozen_string_literal: true

puts 'Welcome to a CLI version of the historical game of Chess!'
puts 'Please type in "load" or "new" to load or begin a new game, respectively.'

input = gets.chomp

until %w[load new].include?(input)
  puts 'Invalid input!'
  input = gets.chomp
end

if input == 'new'
  puts 'Please enter a name for player one, or press enter to use the default.'
  input = gets.chomp
  p1_name = input == '' ? 'Player 1' : input

  puts 'Please enter a name for player two, or press enter to use the default.'
  input = gets.chomp
  p2_name = input == '' ? 'Player 2' : input
end
