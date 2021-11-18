# frozen_string_literal: true

# EnPassant contains methods necessary to check and execute en passant
#
# #update_en_passant returns a lambda containing a method call representing the next move in game
#   Said lambda is used in Chess#complete_move to determine what the next move will be
#   It implictly returns nil if none of the conditions are satisfied
#
# #add_en_passant checks the adjacent spaces on the board for en passant
# #check_en_passant adds the move itself if all conditions are met
# #en_passant performs the move itself
module EnPassant
  def update_en_passant(piece, origin, destination)
    if piece.type == 'Pawn' &&
       piece.en_passant_move.any?
      next_move = if destination == piece.en_passant_move[0]
                    -> { en_passant(piece, origin, destination) }
                  else
                    -> { game_board.move_piece(piece, origin, destination) }
                  end

      piece.en_passant_move = []
      next_move
    elsif piece.type == 'Pawn' &&
          pawn_hop_used?(piece, origin, destination)
      add_en_passant(destination)
      -> { game_board.move_piece(piece, origin, destination) }
    end
  end

  def add_en_passant(capture_location)
    direction = turn.color == 'white' ? [0, -1] : [0, 1]
    en_passant_move = traverse(capture_location, direction)
    enemy_color = turn.color == 'white' ? 'black' : 'white'

    left_piece_location = traverse(capture_location, [-1, 0])
    check_en_passant(left_piece_location, en_passant_move, enemy_color)

    right_piece_location = traverse(capture_location, [1, 0])
    check_en_passant(right_piece_location, en_passant_move, enemy_color)
  end

  def check_en_passant(location, en_passant_move, enemy_color)
    return if location.nil?

    piece = game_board.board[location].value
    return if piece == ' '

    if piece.type == 'Pawn' &&
       piece.moves == 3 &&
       piece.color == enemy_color
      piece.en_passant_move << en_passant_move
    end
  end

  def en_passant(piece, origin, destination)
    direction = turn.color == 'white' ? [0, -1] : [0, 1]
    capturable_enemy = traverse(destination, direction)

    game_board.move_piece(piece, origin, destination)
    game_board.clear_space(capturable_enemy)
  end
end
