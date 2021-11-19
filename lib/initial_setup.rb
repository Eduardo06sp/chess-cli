# frozen_string_literal: true

module InitialSetup
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
end
