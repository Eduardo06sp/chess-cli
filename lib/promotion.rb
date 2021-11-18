# frozen_string_literal: true

module Promotion
  def check_promotion(piece, origin, destination)
    if piece.type == 'Pawn' &&
       final_rank?(destination)
      -> { promotion_prompt(origin, destination) }
    end
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
