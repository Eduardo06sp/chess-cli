# frozen_string_literal: true

module GenerateMoves
  def generate_legal_moves(piece_location)
    piece = game_board.board[piece_location].value

    x_values = ('a'..'h').to_a
    current_x_index = x_values.index(piece_location[0])
    current_y = piece_location[1].to_i

    case piece.type
    when 'Pawn'
      generate_pawn_moves(piece, x_values, current_x_index, current_y)
    when 'King'
      generate_king_moves(piece, x_values, current_x_index, current_y)
    when 'Knight'
      generate_knight_moves(piece, x_values, current_x_index, current_y)
    else
      generate_repeated_moves(piece, x_values, current_x_index, current_y)
    end

    generate_protecting_moves
  end

  def generate_protecting_moves
    king_location = locate_piece(turn.color, 'King')
    protecting_pieces = protecting_pieces_locations(king_location)

    protecting_pieces.each do |protecting_piece, v|
      piece = game_board.board[protecting_piece].value
      attacker = v[:attacker]

      piece.legal_moves = [attacker] if piece.legal_moves.include?(attacker)
    end
  end

  def generate_king_moves(piece, x_values, old_x, old_y)
    modify_king_castling(piece)
    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)

    location = "#{x_values[old_x]}#{old_y}"
    moves_under_attack = moves_under_attack(location) +
                         potentially_under_attack(location) +
                         captures_under_attack(location)

    piece.legal_moves -= moves_under_attack.uniq
  end

  def generate_knight_moves(piece, x_values, old_x, old_y)
    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)
  end

  def generate_pawn_moves(piece, x_values, old_x, old_y)
    pawn_hop = piece.color == 'white' ? [0, 2] : [0, -2]

    if !piece.moved && pawn_hop_possible?(piece, old_x, old_y)
      piece.movement_directions << pawn_hop unless piece.movement_directions.include?(pawn_hop)
    else
      piece.movement_directions.delete(pawn_hop)
    end

    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)
    remove_occupied_locations(piece)

    piece.legal_moves += generate_capturing_moves(piece, x_values, old_x, old_y)
    piece.legal_moves += piece.en_passant_move
  end

  def pawn_hop_possible?(piece, x, y)
    move = piece.movement_directions[0]
    hop = piece.color == 'white' ? [0, 2] : [0, -2]
    potential_moves = [
      [x + move[0], y + move[1]],
      [x + hop[0], y + hop[1]]
    ]

    potential_moves = potential_moves.map do |potential_move|
      coordinate_to_space(potential_move)
    end

    if space_occupied?(potential_moves[0]) ||
       space_occupied?(potential_moves[1])
      false
    else
      true
    end
  end

  def generate_capturing_moves(piece, x_values, old_x, old_y)
    capturing_moves = []

    piece.capturing_moves.each do |x, y|
      new_coordinates = "#{x_values[old_x + x]}#{old_y + y}"
      new_location = game_board.board[new_coordinates]

      next if new_location.nil? ||
              space_empty?(new_location) ||
              piece.color == new_location.value.color

      capturing_moves << new_coordinates
    end

    capturing_moves
  end

  def generate_single_moves(piece, x_values, old_x, old_y)
    single_moves = []

    piece.movement_directions.each do |x, y|
      new_coordinates = "#{x_values[old_x + x]}#{old_y + y}"
      new_location = game_board.board[new_coordinates]

      next if new_location.nil? ||
              (old_x + x).negative? ||
              (old_y + y).negative?

      if space_empty?(new_location) ||
         piece.color != new_location.value.color
        single_moves << new_coordinates
      end
    end

    single_moves
  end

  def generate_repeated_moves(piece, x_values, old_x, old_y)
    piece.movement_directions.each do |x, y|
      new_x = old_x + x
      new_y = old_y + y
      new_coordinates = "#{x_values[new_x]}#{new_y}"
      new_location = game_board.board[new_coordinates]

      until new_x.negative? || new_y.negative?
        break if new_location.nil?

        if space_empty?(new_location)
          piece.legal_moves << new_coordinates
        else
          break if piece.color == new_location.value.color

          piece.legal_moves << new_coordinates
          break
        end

        new_x += x
        new_y += y
        new_coordinates = "#{x_values[new_x]}#{new_y}"
        new_location = game_board.board[new_coordinates]
      end
    end
  end
end
