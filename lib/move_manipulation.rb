# frozen_string_literal: true

# MoveManipulation contains methods regarding move calculation
module MoveManipulation
  def traverse(origin, direction)
    coordinates = space_to_coordinate(origin)
    new_x = coordinates[0] + direction[0]
    new_y = coordinates[1] + direction[1]
    new_coordinates = [new_x, new_y]

    return nil if out_of_boundaries?(new_coordinates)

    coordinate_to_space(new_coordinates)
  end

  def out_of_boundaries?(coordinates)
    coordinates[0] > 7 ||
      coordinates[1] > 8 ||
      coordinates[0].negative? ||
      coordinates[1] < 1
  end

  def piece_can_capture?(piece_location)
    piece = game_board.board[piece_location].value
    piece.legal_moves.any? do |legal_move|
      space_occupied?(legal_move)
    end
  end

  def space_to_coordinate(space)
    x_values = ('a'..'h').to_a

    x_coordinate = x_values.index(space[0])
    y_coordinate = space[1].to_i

    [x_coordinate, y_coordinate]
  end

  def coordinate_to_space(coordinate)
    x_values = ('a'..'h').to_a

    x_value = x_values[coordinate[0]]
    y_value = coordinate[1].to_s

    "#{x_value}#{y_value}"
  end

  def direction_of_travel(piece_location, adjacent_space)
    piece_coordinate = space_to_coordinate(piece_location)
    adjacent_coordinate = space_to_coordinate(adjacent_space)

    x_difference = adjacent_coordinate[0] - piece_coordinate[0]
    y_difference = adjacent_coordinate[1] - piece_coordinate[1]

    [x_difference, y_difference]
  end

  def pawn_capturable_spaces(origin)
    piece = game_board.board[origin].value
    capturable_spaces = []
    x_values = ('a'..'h').to_a
    old_x, old_y = space_to_coordinate(origin)

    piece.capturing_moves.each do |x, y|
      new_coordinates = "#{x_values[old_x + x]}#{old_y + y}"
      new_location = game_board.board[new_coordinates]

      next if new_location.nil?

      capturable_spaces << new_coordinates if space_empty?(new_location)
    end

    capturable_spaces
  end

  def single_move_piece?(piece)
    piece.type == 'King' ||
      piece.type == 'Knight' ||
      piece.type == 'Pawn'
  end

  def reset_legal_moves(color)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      piece_location = game_board.board[space]
      piece = piece_location.value

      piece.legal_moves = [] if piece.color == color
    end
  end

  def clear_legal_moves
    reset_legal_moves('white')
    reset_legal_moves('black')
  end

  def refresh_legal_moves
    opponent_color = turn.color == 'white' ? 'black' : 'white'

    clear_legal_moves
    update_legal_moves(opponent_color)
    update_legal_moves(turn.color)
  end

  def pawn_hop_used?(piece, origin, destination)
    return unless piece.type == 'Pawn'

    pawn_hop = [[0, 2], [0, -2]]
    difference = direction_of_travel(origin, destination)

    pawn_hop.include?(difference)
  end

  def space_occupied?(coordinate, color = nil)
    location = game_board.board[coordinate]

    if color.nil?
      location.value != ' '
    else
      location.value != ' ' &&
        location.value.color == color
    end
  end

  def update_legal_moves(color)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      piece_location = game_board.board[space]
      piece = piece_location.value

      generate_legal_moves(space) if piece.color == color
    end
  end

  def space_empty?(location)
    location.value.instance_of?(String)
  end

  def under_attack?(coordinate)
    opponent_color = turn.color == 'white' ? 'black' : 'white'

    game_board.board.each do |_space, cell|
      next if cell.value == ' '

      if cell.value.color == opponent_color &&
         cell.value.legal_moves.include?(coordinate)
        return true
      end
    end

    false
  end
end
