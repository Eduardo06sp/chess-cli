# frozen_string_literal: true

require_relative 'game_board'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'
require_relative 'pawn'

class Chess
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
    game_board.add_piece(Rook.new(color), "a#{rank}")
    game_board.add_piece(Knight.new(color), "b#{rank}")
    game_board.add_piece(Bishop.new(color), "c#{rank}")
    game_board.add_piece(Queen.new(color), "d#{rank}")

    game_board.add_piece(King.new(color), "e#{rank}")

    game_board.add_piece(Bishop.new(color), "f#{rank}")
    game_board.add_piece(Knight.new(color), "g#{rank}")
    game_board.add_piece(Rook.new(color), "h#{rank}")
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

  def locate_piece(color, type)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      if cell.value.color == color &&
         cell.value.type == type

        return space
      end
    end
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
    play_round until game_over?
  end

  def play_round
    selected_piece_location = request_piece_selection
  end

  def request_piece_selection
    puts "#{turn.name}, please select a gamepiece."
    input = gets.chomp
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)

    if king_in_check?
    else
      available_pieces = player_pieces.select do |space|
        piece = game_board.board[space].value
        piece.legal_moves.any?
      end
    end

    validate_input(input, available_pieces)
  end

  def request_destination(piece)
    puts "#{turn.name}, please make a move."
    input = gets.chomp
  end

  def directions_under_attack(piece_location)
    piece = game_board.board[piece_location].value

    piece.legal_moves.select do |move|
      under_attack?(move)
    end
  end

  def attacking_pieces(piece_location)
  end

  def generate_legal_moves(piece_location)
    piece = game_board.board[piece_location].value

    x_values = ('a'..'h').to_a
    current_x_index = x_values.index(piece_location[0])
    current_y = piece_location[1].to_i

    if piece.type == 'Knight' ||
       piece.type == 'King' ||
       piece.type == 'Pawn'
      generate_single_moves(piece, x_values, current_x_index, current_y)
    else
      generate_repeated_moves(piece, x_values, current_x_index, current_y)
    end
  end

  def generate_single_moves(piece, x_values, old_x, old_y)
    piece.movement_directions.each do |x, y|
      new_coordinates = "#{x_values[old_x + x]}#{old_y + y}"
      new_location = game_board.board[new_coordinates]

      next if new_location.nil? ||
              (old_x + x).negative? ||
              (old_y + y).negative?

      if space_empty?(new_location) ||
         !same_color_piece?(new_location)
        piece.legal_moves << new_coordinates
      end
    end
  end

  def generate_repeated_moves(piece, x_values, old_x, old_y)
    piece.movement_directions.each do |x, y|
      new_x = old_x + x
      new_y = old_y + y
      new_coordinates = "#{x_values[new_x]}#{new_y}"
      new_location = game_board.board[new_coordinates]

      until new_x.negative? || new_y.negative?
        break if new_location.nil?

        if space_empty?(new_location)
          piece.legal_moves << new_coordinates
        else
          break if same_color_piece?(new_location)

          piece.legal_moves << new_coordinates
          break
        end

        new_x += x
        new_y += y
        new_coordinates = "#{x_values[new_x]}#{new_y}"
        new_location = game_board.board[new_coordinates]
      end
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

  def same_color_piece?(location)
    location.value.color == turn.color
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

  def validate_input(input, valid_entries)
    until valid_entries.include?(input)
      puts 'Invalid input!'
      input = gets.chomp
    end

    input
  end

  def game_over?
    white_king_location = locate_piece('white', 'King')
    black_king_location = locate_piece('black', 'King')
    white_king = game_board.board[white_king_location].value
    black_king = game_board.board[black_king_location].value

    return true if white_king.checkmated || black_king.checkmated

    false
  end
end
