# frozen_string_literal: true

# Castling contains all logic necessary to enable castling in the game
#
# Two methods check if castling is even possible (with the use of some helper methods),
# and return a lambda
#   The lambda is stored in Chess#complete_move as a variable (next_move)
#   and then returned in Chess#complete_move
#
# #modify_king_castling is used to give the King an extra move that allows castling
#
# Then two other methods manipulate the board to perform the castling moves
module Castling
  def check_queenside_castling(piece, destination)
    if piece.type == 'King' &&
       queenside_castling_possible? &&
       %w[c1 c8].include?(destination)
      -> { queenside_castle }
    elsif piece.type == 'Rook' &&
          piece.id == 1 &&
          queenside_castling_possible? &&
          %w[d1 d8].include?(destination)
      -> { queenside_castle }
    end
  end

  def check_kingside_castling(piece, destination)
    if piece.type == 'King' &&
       kingside_castling_possible? &&
       %w[g1 g8].include?(destination)
      -> { kingside_castle }
    elsif piece.type == 'Rook' &&
          piece.id == 2 &&
          kingside_castling_possible? &&
          %w[f1 f8].include?(destination)
      -> { kingside_castle }
    end
  end

  def modify_king_castling(piece)
    if queenside_castling_possible?
      piece.movement_directions << [-2, 0]
    else
      piece.movement_directions.delete([-2, 0])
    end

    if kingside_castling_possible?
      piece.movement_directions << [2, 0]
    else
      piece.movement_directions.delete([2, 0])
    end
  end

  def queenside_castling_possible?
    king = game_board.board[locate_piece(turn.color, 'King')].value
    return if locate_piece(turn.color, 'Rook', 1).nil?

    rook = game_board.board[locate_piece(turn.color, 'Rook', 1)].value
    empty_spaces_required = if turn.color == 'white'
                              %w[b1 c1 d1]
                            else
                              %w[b8 c8 d8]
                            end
    king_spaces_required = if turn.color == 'white'
                             %w[c1 d1]
                           else
                             %w[c8 d8]
                           end

    return if rook.moved || king.moved
    return if empty_spaces_required.any? { |space| space_occupied?(space) }
    return if king_spaces_required.any? { |space| under_attack?(space) }
    return if king_in_check?

    true
  end

  def kingside_castling_possible?
    king = game_board.board[locate_piece(turn.color, 'King')].value
    return if locate_piece(turn.color, 'Rook', 2).nil?

    rook = game_board.board[locate_piece(turn.color, 'Rook', 2)].value
    empty_spaces_required = if turn.color == 'white'
                              %w[f1 g1]
                            else
                              %w[f8 g8]
                            end

    return if rook.moved || king.moved
    return if empty_spaces_required.any? { |space| space_occupied?(space) }
    return if empty_spaces_required.any? { |space| under_attack?(space) }
    return if king_in_check?

    true
  end

  def queenside_castle
    if turn.color == 'white'
      king = game_board.board['e1'].value
      rook = game_board.board['a1'].value
      game_board.move_piece(king, 'e1', 'c1')
      game_board.move_piece(rook, 'a1', 'd1')
    else
      king = game_board.board['e8'].value
      rook = game_board.board['a8'].value
      game_board.move_piece(king, 'e8', 'c8')
      game_board.move_piece(rook, 'a8', 'd8')
    end
  end

  def kingside_castle
    if turn.color == 'white'
      king = game_board.board['e1'].value
      rook = game_board.board['h1'].value
      game_board.move_piece(king, 'e1', 'g1')
      game_board.move_piece(rook, 'h1', 'f1')
    else
      king = game_board.board['e8'].value
      rook = game_board.board['h8'].value
      game_board.move_piece(king, 'e8', 'g8')
      game_board.move_piece(rook, 'h8', 'f8')
    end
  end
end
