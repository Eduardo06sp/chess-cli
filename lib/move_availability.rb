# frozen_string_literal: true

module MoveAvailability
  def available_moves(piece_location)
    piece = game_board.board[piece_location].value

    if king_in_check? && piece.type == 'King'
      piece.legal_moves
    elsif king_in_check?
      unchecking_moves(piece_location)
    else
      piece.legal_moves
    end
  end

  def unchecking_moves(piece_location)
    piece = game_board.board[piece_location].value
    king_location = locate_piece(turn.color, 'King')
    attacking_piece = { location: attacking_pieces_locations(king_location)[0],
                        path: attack_paths(king_location)[0] }

    available_moves = if attacking_piece[:path].nil?
                        []
                      else
                        piece.legal_moves.intersection(attacking_piece[:path])
                      end

    available_moves << attacking_piece[:location] if piece.legal_moves.include?(attacking_piece[:location])

    available_moves.uniq
  end

  def attack_paths(king_location)
    directions_under_attack = directions_under_attack(king_location)
    attack_paths = []

    directions_under_attack.each do |space|
      attack_direction = direction_of_travel(king_location, space)

      attack_paths << calculate_attack_path(attack_direction, space)
    end

    attack_paths
  end

  def calculate_attack_path(attack_direction, origin)
    current_coordinates = space_to_coordinate(origin)
    current_space_value = ' '
    attack_path = [origin]

    loop do
      current_x = current_coordinates[0] + attack_direction[0]
      current_y = current_coordinates[1] + attack_direction[1]
      current_coordinates = [current_x, current_y]
      current_space = coordinate_to_space(current_coordinates)
      current_space_value = game_board.board[current_space].value
      break unless current_space_value == ' '

      attack_path << current_space
    end

    attack_path
  end

  def captures_under_attack(piece_location)
    piece = game_board.board[piece_location].value
    opponent_color = turn.color == 'white' ? 'black' : 'white'
    opponent_pieces = locate_player_pieces(opponent_color)
    checking_captures = []

    captures = piece.legal_moves.select do |legal_move|
      space_occupied?(legal_move, opponent_color)
    end

    opponent_pieces.each do |opponent_location|
      opponent_piece = game_board.board[opponent_location].value
      opponent_piece.movement_directions.each do |direction|
        tmp = opponent_location

        loop do
          tmp = traverse(tmp, direction)

          break if tmp.nil? || space_occupied?(tmp)
        end

        next if tmp.nil?

        current_piece = game_board.board[tmp].value
        if current_piece.color == opponent_color &&
           captures.include?(tmp)
          checking_captures << tmp
        end
      end
    end

    checking_captures
  end

  def potentially_under_attack(piece_location)
    piece = game_board.board[piece_location].value
    attack_directions = directions_under_attack(piece_location)
    moves_under_attack = []

    attack_directions.each do |space|
      attack_direction = direction_of_travel(piece_location, space)
      opposite_direction = [-attack_direction[0], -attack_direction[1]]

      opposite_space = traverse(piece_location, opposite_direction)

      moves_under_attack << opposite_space if piece.legal_moves.include?(opposite_space)
    end

    moves_under_attack
  end

  def moves_under_attack(piece_location)
    piece = game_board.board[piece_location].value
    opponent_color = piece.color == 'white' ? 'black' : 'white'
    opponent_pieces = locate_player_pieces(opponent_color)
    moves_under_attack = []

    opponent_pieces.each do |opponent_location|
      opponent_piece = game_board.board[opponent_location].value

      piece.legal_moves.each do |legal_move|
        opponent_moves = if opponent_piece.type == 'Pawn'
                           pawn_capturable_spaces(opponent_location)
                         else
                           opponent_piece.legal_moves
                         end
        moves_under_attack << legal_move if
        opponent_moves.include?(legal_move)
      end
    end

    moves_under_attack.uniq
  end

  def directions_under_attack(piece_location)
    piece = game_board.board[piece_location].value
    attacking_pieces = attacking_pieces_locations(piece_location)

    find_attack_directions(piece, piece_location, attacking_pieces)
  end

  def find_attack_directions(piece, piece_location, attacking_pieces)
    x_values = ('a'..'h').to_a
    coordinates = space_to_coordinate(piece_location)
    single_moves = generate_single_moves(piece, x_values, coordinates[0], coordinates[1])

    directions_under_attack = []

    attacking_pieces.each do |opponent_location|
      opponent_piece = game_board.board[opponent_location].value

      next if single_move_piece?(opponent_piece)

      opponent_piece.movement_directions.each do |direction|
        tmp = opponent_location

        loop do
          prev = tmp
          tmp = traverse(tmp, direction)

          break if tmp.nil?

          current_piece = game_board.board[tmp].value

          next if current_piece == ' '
          break if current_piece.color == piece.color && piece.type != 'King'

          if current_piece.type == 'King'
            directions_under_attack << prev
            break
          end
        end
      end
    end

    directions_under_attack
  end

  def attacking_pieces_locations(piece_location)
    opponent_color = turn.color == 'white' ? 'black' : 'white'
    attacking_pieces_locations = []

    game_board.board.each do |space, cell|
      next if cell.value == ' '

      if cell.value.color == opponent_color &&
         cell.value.legal_moves.include?(piece_location)
        attacking_pieces_locations << space
      end
    end

    attacking_pieces_locations
  end
end
