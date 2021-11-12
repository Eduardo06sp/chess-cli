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
      p1 = create_player('one')
      p2_color = p1.color == 'white' ? 'black' : 'white'
      p2 = create_player('two', p2_color)
      new_game = Chess.new(p1, p2)
      new_game.add_initial_pieces
      new_game.play
    else
      load_prompt
    end
  end

  def create_player(order, color = 'white')
    number = order == 'one' ? '1' : '2'

    puts "Please enter a name for player #{order}, or press enter to use the default."
    input = gets.chomp
    player_name = input == '' ? "Player #{number}" : input

    if order == 'one'
      puts 'Please enter a color for player one, or press enter to use the default (white).'
      input = gets.chomp
      input = validate_input(input, ['', 'white', 'black'], 'Please enter a color or press enter without typing.')
      color = input == '' ? color : input
    end

    Player.new(player_name, color)
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
