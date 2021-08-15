# frozen_string_literal: true

puts 'Welcome to a CLI version of the historical game of Chess!'
puts 'Please type in "load" or "new" to load or begin a new game, respectively.'

input = gets.chomp

until %w[load new].include?(input)
  puts 'Invalid input!'
  input = gets.chomp
end