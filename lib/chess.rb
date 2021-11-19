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
require_relative 'initial_setup'
require_relative 'generate_moves'

require_relative 'move_availability'
require_relative 'piece_availability'
require_relative 'move_manipulation'
require_relative 'piece_manipulation'

require_relative 'castling'
require_relative 'en_passant'
require_relative 'promotion'
require_relative 'draw'

# Chess contains the methods required to play rounds
# and end the game (except for draws)
class Chess
  include TerminalInterface
  include Save
  include InitialSetup
  include GenerateMoves

  include MoveAvailability
  include PieceAvailability
  include MoveManipulation
  include PieceManipulation

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
