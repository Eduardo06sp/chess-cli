# frozen_string_literal: true

require_relative 'chess'
require_relative 'player'

class Main
  def introduction
    puts 'Welcome to a CLI version of the historical game of Chess!'
    puts 'Please type in "load" or "new" to load or begin a new game, respectively.'

    input = gets.chomp
    input = validate_input(input, %w[load new], 'Please type "load" or "new".')

    if input == 'new'
      puts 'Please enter a name for player one, or press enter to use the default.'
      input = gets.chomp
      p1_name = input == '' ? 'Player 1' : input

      puts 'Please enter a name for player two, or press enter to use the default.'
      input = gets.chomp
      p2_name = input == '' ? 'Player 2' : input

      puts 'Please enter a color for player one, or press enter to use the default (white).'
      input = gets.chomp

      until ['', 'white', 'black'].include?(input)
        puts 'Please enter a color or press enter without typing.'
        input = gets.chomp
      end

      p1_color = input == '' ? 'white' : input
      p2_color = p1_color == 'white' ? 'black' : 'white'

      p1 = Player.new(p1_name, p1_color)
      p2 = Player.new(p2_name, p2_color)
      new_game = Chess.new(p1, p2)
      new_game.add_initial_pieces
      new_game.play
    else
      load_prompt
    end
  end

  def load_prompt
    if !Dir.exist?('saves') || Dir.empty?('saves')
      puts 'No saves present!'
    else
      saves = Dir.children('saves').sort
      load_prompt = 'Please enter a slot number to load.'
      puts load_prompt
      puts saves
      load_selection = gets.chomp
      load_selection = validate_input(load_selection.to_i, (1..saves.count).to_a, load_prompt)

      load_game(saves, load_selection)
    end
  end

  def load_game(saves, selection)
    puts 'Loading...'
    save = File.open("saves/#{saves[selection.to_i - 1]}", 'r') do |file|
      YAML.load(file)
    end
    save.play
  end

  def validate_input(input, valid_entries, hint)
    until valid_entries.include?(input)
      puts "Invalid input! #{hint}"
      input = gets.chomp
    end

    input
  end
end

new_game = Main.new
new_game.introduction
