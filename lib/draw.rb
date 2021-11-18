# frozen_string_literal: true

module Draw
  def draw?
    insufficient_material?
    stalemate?
  end

  def insufficient_material?
    white_piece_locations = locate_player_pieces('white')
    black_piece_locations = locate_player_pieces('black')

    white_pieces = white_piece_locations.map do |space|
      game_board.board[space].value
    end
    black_pieces = black_piece_locations.map do |space|
      game_board.board[space].value
    end

    king_vs_king?(white_pieces, black_pieces) ||
      king_bishop_vs_king?(white_pieces, black_pieces) ||
      king_bishop_vs_king?(black_pieces, white_pieces) ||
      king_knight_vs_king?(white_pieces, black_pieces) ||
      king_knight_vs_king?(black_pieces, white_pieces)
  end

  def king_vs_king?(white_pieces, black_pieces)
    white_pieces.count { |piece| piece.type == 'King' } == white_pieces.count &&
      black_pieces.count { |piece| piece.type == 'King' } == black_pieces.count
  end

  def king_bishop_vs_king?(player_pieces, opposite_player_pieces)
    (player_pieces.count { |piece| piece.type == 'King' } +
      player_pieces.count { |piece| piece.type == 'Bishop' } == player_pieces.count) &&
      (opposite_player_pieces.count { |piece| piece.type == 'King' } == opposite_player_pieces.count)
  end

  def king_knight_vs_king?(player_pieces, opposite_player_pieces)
    (player_pieces.count { |piece| piece.type == 'King' } +
      player_pieces.count { |piece| piece.type == 'Knight' } == player_pieces.count) &&
      (opposite_player_pieces.count { |piece| piece.type == 'King' } == opposite_player_pieces.count)
  end

  def stalemate?
    player_pieces = locate_player_pieces(turn.color)
    available_pieces = available_pieces(player_pieces)

    !king_in_check? && available_pieces.empty?
  end

  def final_rank?(space)
    current_rank = space[1]
    last_rank = turn.color == 'white' ? '8' : '1'

    current_rank == last_rank
  end

  def end_in_draw
    display_interface(end_message('draw'))
    exit
  end
end
