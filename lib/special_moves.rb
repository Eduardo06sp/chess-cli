# frozen_string_literal: true

module SpecialMoves
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
