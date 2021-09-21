# frozen_string_literal: true

require_relative 'terminal_interface'
require_relative 'game_board'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

class Chess
  include TerminalInterface

  attr_accessor :turn
  attr_reader :player_one, :player_two, :game_board

  def initialize(player_one, player_two)
    @player_one = player_one
    @player_two = player_two
    @game_board = GameBoard.new
    @turn = first_turn
  end

  def first_turn
    return player_one if player_one.color == 'white'

    player_two
  end

  def fill_king_rank(color, rank)
    game_board.add_piece(Rook.new(color), "a#{rank}")
    game_board.add_piece(Knight.new(color), "b#{rank}")
    game_board.add_piece(Bishop.new(color), "c#{rank}")
    game_board.add_piece(Queen.new(color), "d#{rank}")

    game_board.add_piece(King.new(color), "e#{rank}")

    game_board.add_piece(Bishop.new(color), "f#{rank}")
    game_board.add_piece(Knight.new(color), "g#{rank}")
    game_board.add_piece(Rook.new(color), "h#{rank}")
  end

  def fill_pawn_rank(color, rank)
    files = ('a'..'h').to_a

    files.each do |file|
      game_board.add_piece(Pawn.new(color), "#{file}#{rank}")
    end
  end

  def add_initial_pieces
    fill_king_rank('white', '1')
    fill_pawn_rank('white', '2')

    fill_pawn_rank('black', '7')
    fill_king_rank('black', '8')
  end

  def locate_piece(color, type)
    game_board.board.each do |space, cell|
      next if cell.value == ' '

      if cell.value.color == color &&
         cell.value.type == type

        return space
      end
    end
  end

  def locate_player_pieces(color)
    player_pieces = []

    game_board.board.each do |space, cell|
      next if cell.value == ' '

      player_pieces << space if cell.value.color == color
    end

    player_pieces
  end

  def play
    play_round until game_over?
  end

  def play_round
    refresh_legal_moves
    selected_piece_location = request_piece_selection
    piece = game_board.board[selected_piece_location].value
    destination = request_destination(selected_piece_location)

    game_board.move_piece(piece, selected_piece_location, destination)
    piece.moved = true if piece.type == 'Pawn'

    clear_legal_moves
    change_turn
  end

  def change_turn
    self.turn = if turn == player_one
                  player_two
                else
                  player_one
                end
  end

  def request_piece_selection
    display_interface("#{turn.name}, please select a gamepiece.")
    input = gets.chomp
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)
    available_pieces = available_pieces(player_pieces)

    validate_input(input, available_pieces)
  end


  def request_destination(piece)
    display_interface("#{turn.name}, please make a move.")
    input = gets.chomp
    available_moves = available_moves(piece)

    validate_input(input, available_moves)
  end

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

    available_moves
  end

  def available_pieces(player_pieces)
    if king_in_check?
      king_location = locate_piece(turn.color, 'King')
      attacking_pieces_locations = attacking_pieces_locations(king_location)

      available_pieces = unchecking_pieces(attacking_pieces_locations, king_location, player_pieces)
    else
      available_pieces = player_pieces.select do |space|
        piece = game_board.board[space].value
        piece.legal_moves.any?
      end
    end

    available_pieces.uniq
  end

  def unchecking_pieces(attacking_pieces_locations, king_location, player_pieces)
    check_blocking_pieces = check_blocking_pieces(king_location, player_pieces, attacking_pieces_locations)

    if attacking_pieces_locations.count == 1
      (player_pieces.select do |space|
        piece = game_board.board[space].value

        piece.type == 'King' ||
          piece.legal_moves.include?(attacking_pieces_locations[0])
      end) + check_blocking_pieces
    else
      [king_location]
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

  def direction_of_travel(piece_location, adjacent_space)
    piece_coordinate = space_to_coordinate(piece_location)
    adjacent_coordinate = space_to_coordinate(adjacent_space)

    x_difference = adjacent_coordinate[0] - piece_coordinate[0]
    y_difference = adjacent_coordinate[1] - piece_coordinate[1]

    [x_difference, y_difference]
  end

  def check_blocking_pieces(king_location, player_pieces, attacking_pieces)
    check_blocking_pieces = []

    attack_paths = attack_paths(king_location).flatten
    player_pieces.each do |space|
      piece = game_board.board[space].value
      next if piece.type == 'King'

      attack_paths.each do |attack_space|
        if piece.legal_moves.include?(attack_space)
          check_blocking_pieces << space
        end
      end
    end

    check_blocking_pieces
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

      single_moves.each do |legal_move|
        if opponent_piece.legal_moves.include?(legal_move)

          directions_under_attack << legal_move
        end
      end
    end

    directions_under_attack
  end

  def single_move_piece?(piece)
    piece.type == 'King' ||
      piece.type == 'Knight' ||
      piece.type == 'Pawn'
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
    clear_legal_moves
    update_legal_moves('white')
    update_legal_moves('black')
  end

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
  end

  def generate_king_moves(piece, x_values, old_x, old_y)
    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)

    location = "#{x_values[old_x]}#{old_y}"
    moves_under_attack = moves_under_attack(location)

    piece.legal_moves -= moves_under_attack
  end

  def generate_knight_moves(piece, x_values, old_x, old_y)
    location = "#{x_values[old_x]}#{old_y}"

    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)
  end

  def generate_pawn_moves(piece, x_values, old_x, old_y)
    pawn_hop = piece.color == 'white' ? [0, 2] : [0, -2]

    if pawn_hop_possible?(piece, old_x, old_y) && !piece.moved
      piece.movement_directions << pawn_hop unless piece.movement_directions.include?(pawn_hop)
    else
      piece.movement_directions.delete(pawn_hop)
    end

    piece.legal_moves = generate_single_moves(piece, x_values, old_x, old_y)
    remove_occupied_locations(piece)

    piece.legal_moves += generate_capturing_moves(piece, x_values, old_x, old_y)
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

  def remove_occupied_locations(piece)
    piece.legal_moves.each do |move|
      piece.legal_moves.delete(move) if space_occupied?(move)
    end
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
    update_legal_moves(opponent_color)

    game_board.board.each do |_space, cell|
      next if cell.value == ' '

      if cell.value.color == opponent_color &&
         cell.value.legal_moves.include?(coordinate)
        return true
      end
    end

    false
  end

  def king_in_check?
    king_location = locate_piece(turn.color, 'King')

    under_attack?(king_location)
  end

  def validate_input(input, valid_entries)
    until valid_entries.include?(input)
      display_interface('Invalid input!')
      input = gets.chomp
    end

    input
  end

  def game_over?
    white_king_location = locate_piece('white', 'King')
    black_king_location = locate_piece('black', 'King')
    white_king = game_board.board[white_king_location].value
    black_king = game_board.board[black_king_location].value

    return true if white_king.checkmated || black_king.checkmated

    false
  end
end
