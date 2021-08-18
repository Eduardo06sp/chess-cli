# frozen_string_literal: true

require_relative 'game_board'

class Chess
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
    game_board.board.add_piece(Rook.new(color), "a#{rank}")
    game_board.board.add_piece(Knight.new(color), "b#{rank}")
    game_board.board.add_piece(Bishop.new(color), "c#{rank}")
    game_board.board.add_piece(Queen.new(color), "d#{rank}")

    game_board.board.add_piece(King.new(color), "e#{rank}")

    game_board.board.add_piece(Bishop.new(color), "f#{rank}")
    game_board.board.add_piece(Knight.new(color), "g#{rank}")
    game_board.board.add_piece(Rook.new(color), "h#{rank}")
  end

  def fill_pawn_rank(color, rank)
    files = ('a'..'h').to_a

    files.each do |file|
      game_board.board.add_piece(Pawn.new(color), "#{file}#{rank}")
    end
  end

  def add_initial_pieces
    fill_king_rank('white', '1')
    fill_pawn_rank('white', '2')

    fill_pawn_rank('black', '7')
    fill_king_rank('black' '8')
  end
end
