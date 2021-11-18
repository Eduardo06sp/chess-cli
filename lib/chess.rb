# frozen_string_literal: true

require 'yaml'

require_relative 'terminal_interface'
require_relative 'game_board'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

require_relative 'save'
require_relative 'generate_moves'
require_relative 'move_availability'
require_relative 'piece_availability'
require_relative 'castling'
require_relative 'en_passant'
require_relative 'promotion'
require_relative 'draw'

class Chess
  include TerminalInterface
  include Save
  include GenerateMoves
  include MoveAvailability
  include PieceAvailability
  include Castling
  include EnPassant
  include Promotion
  include Draw

  attr_accessor :turn
  attr_reader :player_one, :player_two, :game_board

  def initialize(player_one, player_two)
    @player_one = player_one
    @player_two = player_two
    @game_board = GameBoard.new
    @turn = first_turn
  end

  def first_turn
    return player_one if player_one.color == 'white'

    player_two
  end

  def fill_king_rank(color, rank)
    game_board.add_piece(Rook.new(color, 1), "a#{rank}")
    game_board.add_piece(Knight.new(color, 1), "b#{rank}")
    game_board.add_piece(Bishop.new(color, 1), "c#{rank}")
    game_board.add_piece(Queen.new(color), "d#{rank}")

    game_board.add_piece(King.new(color), "e#{rank}")

    game_board.add_piece(Bishop.new(color, 2), "f#{rank}")
    game_board.add_piece(Knight.new(color, 2), "g#{rank}")
    game_board.add_piece(Rook.new(color, 2), "h#{rank}")
  end

  def fill_pawn_rank(color, rank)
    files = ('a'..'h').to_a

    files.each do |file|
      game_board.add_piece(Pawn.new(color), "#{file}#{rank}")
    end
  end

  def add_initial_pieces
    fill_king_rank('white', '1')
    fill_pawn_rank('white', '2')

    fill_pawn_rank('black', '7')
    fill_king_rank('black', '8')
  end

  def locate_piece(color, type, id = 0)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      if cell.value.color == color &&
         cell.value.type == type &&
         cell.value.id == id

        return space
      end
    end

    nil
  end

  def locate_player_pieces(color)
    player_pieces = []

    game_board.board.each do |space, cell|
      next if cell.value == ' '

      player_pieces << space if cell.value.color == color
    end

    player_pieces
  end

  def play
    until game_over?
      play_round
      refresh_legal_moves
    end

    display_interface(end_message('checkmate'))
  end

  def play_round
    refresh_legal_moves
    user_input = initial_round_prompt
    while user_input == 'save'
      user_input = initial_round_prompt
    end

    selected_piece_location = request_piece_selection(user_input)
    piece = game_board.board[selected_piece_location].value
    destination = request_destination(selected_piece_location)

    complete_move(piece, selected_piece_location, destination).call

    piece.moves += 1 if piece.type == 'Pawn'
    piece.moved = true if piece.type == 'Pawn' ||
                          piece.type == 'Rook' ||
                          piece.type == 'King'
    change_turn
  end

  def complete_move(piece, origin, destination)
    next_move = check_queenside_castling(piece, destination)
    return next_move unless next_move.nil?

    next_move = check_kingside_castling(piece, destination)
    return next_move unless next_move.nil?

    next_move = update_en_passant(piece, origin, destination)
    return next_move unless next_move.nil?

    next_move = check_promotion(piece, origin, destination)
    return next_move unless next_move.nil?

    -> { game_board.move_piece(piece, origin, destination) }
  end

  def change_turn
    self.turn = if turn == player_one
                  player_two
                else
                  player_one
                end
  end

  def initial_round_prompt
    resignation_words = %w[resign quit exit]
    hint = 'Please select a gamepiece.
          You may save at any moment by typing: save.
          You may resign by typing: resign, exit or quit.'
    display_interface(hint)
    user_input = gets.chomp

    end_in_draw if draw?
    resign_game if resignation_words.include?(user_input)
    save_prompt if user_input == 'save'

    user_input
  end

  def request_piece_selection(input)
    hint = 'Please select a gamepiece.'
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)
    available_pieces = available_pieces(player_pieces)

    validate_input(input, available_pieces, hint)
  end

  def request_destination(piece)
    hint = 'Please make a move.

            '
    display_interface(hint)
    input = gets.chomp
    available_moves = available_moves(piece)

    validate_input(input, available_moves, hint)
  end

  def traverse(origin, direction)
    coordinates = space_to_coordinate(origin)
    new_x = coordinates[0] + direction[0]
    new_y = coordinates[1] + direction[1]
    new_coordinates = [new_x, new_y]

    return nil if out_of_boundaries?(new_coordinates)

    coordinate_to_space(new_coordinates)
  end

  def out_of_boundaries?(coordinates)
    coordinates[0] > 7 ||
      coordinates[1] > 8 ||
      coordinates[0] < 0 ||
      coordinates[1] < 1
  end

  def piece_can_capture?(piece_location)
    piece = game_board.board[piece_location].value
    piece.legal_moves.any? do |legal_move|
      space_occupied?(legal_move)
    end
  end

  def space_to_coordinate(space)
    x_values = ('a'..'h').to_a

    x_coordinate = x_values.index(space[0])
    y_coordinate = space[1].to_i

    [x_coordinate, y_coordinate]
  end

  def coordinate_to_space(coordinate)
    x_values = ('a'..'h').to_a

    x_value = x_values[coordinate[0]]
    y_value = coordinate[1].to_s

    "#{x_value}#{y_value}"
  end

  def direction_of_travel(piece_location, adjacent_space)
    piece_coordinate = space_to_coordinate(piece_location)
    adjacent_coordinate = space_to_coordinate(adjacent_space)

    x_difference = adjacent_coordinate[0] - piece_coordinate[0]
    y_difference = adjacent_coordinate[1] - piece_coordinate[1]

    [x_difference, y_difference]
  end

  def pawn_capturable_spaces(origin)
    piece = game_board.board[origin].value
    capturable_spaces = []
    x_values = ('a'..'h').to_a
    old_x, old_y = space_to_coordinate(origin)

    piece.capturing_moves.each do |x, y|
      new_coordinates = "#{x_values[old_x + x]}#{old_y + y}"
      new_location = game_board.board[new_coordinates]

      next if new_location.nil?

      capturable_spaces << new_coordinates if space_empty?(new_location)
    end

    capturable_spaces
  end

  def single_move_piece?(piece)
    piece.type == 'King' ||
      piece.type == 'Knight' ||
      piece.type == 'Pawn'
  end

  def reset_legal_moves(color)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      piece_location = game_board.board[space]
      piece = piece_location.value

      piece.legal_moves = [] if piece.color == color
    end
  end

  def clear_legal_moves
    reset_legal_moves('white')
    reset_legal_moves('black')
  end

  def refresh_legal_moves
    opponent_color = turn.color == 'white' ? 'black' : 'white'

    clear_legal_moves
    update_legal_moves(opponent_color)
    update_legal_moves(turn.color)
  end

  def pawn_hop_used?(piece, origin, destination)
    return unless piece.type == 'Pawn'

    pawn_hop = [[0, 2], [0, -2]]
    difference = direction_of_travel(origin, destination)

    pawn_hop.include?(difference)
  end

  def remove_occupied_locations(piece)
    piece.legal_moves.each do |move|
      piece.legal_moves.delete(move) if space_occupied?(move)
    end
  end

  def space_occupied?(coordinate, color = nil)
    location = game_board.board[coordinate]

    if color.nil?
      location.value != ' '
    else
      location.value != ' ' &&
        location.value.color == color
    end
  end

  def update_legal_moves(color)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      piece_location = game_board.board[space]
      piece = piece_location.value

      generate_legal_moves(space) if piece.color == color
    end
  end

  def space_empty?(location)
    location.value.instance_of?(String)
  end

  def under_attack?(coordinate)
    opponent_color = turn.color == 'white' ? 'black' : 'white'
    update_legal_moves(opponent_color)

    game_board.board.each do |_space, cell|
      next if cell.value == ' '

      if cell.value.color == opponent_color &&
         cell.value.legal_moves.include?(coordinate)
        return true
      end
    end

    false
  end

  def king_in_check?
    king_location = locate_piece(turn.color, 'King')

    under_attack?(king_location)
  end

  def validate_input(input, valid_entries, hint)
    until valid_entries.include?(input)
      display_interface("Invalid input! #{hint}")
      input = gets.chomp
    end

    input
  end

  def resign_game
    opponent = turn.name == player_one.name ? player_two.name : player_one.name

    puts "#{turn.name} has resigned! #{opponent} wins!"
    exit
  end

  def game_over?
    checkmated?
  end

  def checkmated?
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)

    available_pieces = available_pieces(player_pieces)

    king_in_check? && available_pieces.empty?
  end
end
