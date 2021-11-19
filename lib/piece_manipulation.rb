# frozen_string_literal: true

# PieceManipulation contains methods used for piece manipulation
# excluding special moves
module PieceManipulation
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

  def remove_occupied_locations(piece)
    piece.legal_moves.each do |move|
      piece.legal_moves.delete(move) if space_occupied?(move)
    end
  end
end
