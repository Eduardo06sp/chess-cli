# frozen_string_literal: true

module SpecialMoves
  def check_queenside_castling(piece, destination)
    if piece.type == 'King' &&
       queenside_castling_possible? &&
       %w[b1 b8].include?(destination)
      -> { queenside_castle }
    elsif piece.type == 'Rook' &&
          piece.id == 1 &&
          queenside_castling_possible? &&
          %w[c1 c8].include?(destination)
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

  def check_promotion(piece, origin, destination)
    if piece.type == 'Pawn' &&
       final_rank?(destination)
      -> { promotion_prompt(origin, destination) }
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

  def promotion_prompt(origin, destination)
    promotion_pieces = %w[rook knight bishop queen]
    promotion_message = 'You may promote your Pawn to one of the following (in lower-case):
      - Rook
      - Knight
      - Bishop
      - Queen'
    display_interface(promotion_message)
    user_input = gets.chomp
    input = validate_input(user_input, promotion_pieces, promotion_message)

    promote_pawn(input, origin, destination)
  end

  def promote_pawn(input, origin, destination)
    new_piece = Object.const_get(input.capitalize)

    new_piece = if new_piece == Queen
                  new_piece.new(turn.color)
                else
                  new_piece.new(turn.color, 0)
                end

    game_board.clear_space(origin)
    game_board.add_piece(new_piece, destination)
  end
end
