# frozen_string_literal: true

require 'yaml'

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

  def save_prompt
    save = YAML.dump(self)
    Dir.mkdir('saves') unless File.exist?('saves')
    current_saves = Dir.children('saves').sort
    save_number = if current_saves.count < 5
                    current_saves.count + 1
                  else
                    1
                  end

    if current_saves.count == 5
      overwrite_prompt(current_saves, save)
    else
      puts 'Enter the name for your new save. Or type "overwrite" to select a slot to overwrite.'
      save_choice = gets.chomp

      if save_choice == 'overwrite'
        if current_saves.empty?
          puts 'No saves present!'
          save_prompt
        else
          overwrite_prompt(current_saves, save)
        end
      else
        save_game(save_number, save_choice, save)
      end
    end
  end

  def save_game(number, name, save)
    puts 'Saving...'
    File.open("saves/#{number}. #{name}.txt", 'w') do |file|
      file.write(save)
    end
    puts 'Successfully saved.'
  end

  def overwrite_prompt(current_saves, save)
    overwrite_hint = 'Please select the save file number you would like to overwrite.'
    puts overwrite_hint
    puts current_saves
    overwrite_number = gets.chomp

    until current_saves.count.to_s.include?(overwrite_number)
      puts overwrite_hint
      overwrite_number = gets.chomp
    end

    puts 'Enter the name for your new save.'
    overwrite_name = gets.chomp

    save_overwrite(current_saves, overwrite_number, overwrite_name, save)
  end

  def save_overwrite(current_saves, number, name, save)
    puts 'Saving...'
    File.open("saves/#{current_saves[number.to_i - 1]}", 'w') do |file|
      file.write(save)
    end
    File.rename("saves/#{current_saves[number.to_i - 1]}", "saves/#{number}. #{name}")
    puts 'Successfully saved.'
  end

  def first_turn
    return player_one if player_one.color == 'white'

    player_two
  end

  def fill_king_rank(color, rank)
    game_board.add_piece(Rook.new(color, 1), "a#{rank}")
    game_board.add_piece(Knight.new(color, 1), "b#{rank}")
    game_board.add_piece(Bishop.new(color, 1), "c#{rank}")
    game_board.add_piece(Queen.new(color), "d#{rank}")

    game_board.add_piece(King.new(color), "e#{rank}")

    game_board.add_piece(Bishop.new(color, 2), "f#{rank}")
    game_board.add_piece(Knight.new(color, 2), "g#{rank}")
    game_board.add_piece(Rook.new(color, 2), "h#{rank}")
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

  def play
    until game_over?
      play_round
      refresh_legal_moves
    end

    display_interface(end_message('checkmate'))
  end

  def play_round
    refresh_legal_moves
    user_input = initial_round_prompt
    while user_input == 'save'
      user_input = initial_round_prompt
    end

    selected_piece_location = request_piece_selection(user_input)
    piece = game_board.board[selected_piece_location].value
    destination = request_destination(selected_piece_location)

    complete_move(piece, selected_piece_location, destination).call

    piece.moves += 1 if piece.type == 'Pawn'
    piece.moved = true if piece.type == 'Pawn' ||
                          piece.type == 'Rook' ||
                          piece.type == 'King'
    change_turn
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

  def change_turn
    self.turn = if turn == player_one
                  player_two
                else
                  player_one
                end
  end

  def initial_round_prompt
    resignation_words = %w[resign quit exit]
    hint = 'Please select a gamepiece.
          You may save at any moment by typing: save.
          You may resign by typing: resign, exit or quit.'
    display_interface(hint)
    user_input = gets.chomp

    end_in_draw if draw?
    resign_game if resignation_words.include?(user_input)
    save_prompt if user_input == 'save'

    user_input
  end

  def request_piece_selection(input)
    hint = 'Please select a gamepiece.'
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)
    available_pieces = available_pieces(player_pieces)

    validate_input(input, available_pieces, hint)
  end

  def request_destination(piece)
    hint = 'Please make a move.

            '
    display_interface(hint)
    input = gets.chomp
    available_moves = available_moves(piece)

    validate_input(input, available_moves, hint)
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

    available_moves.uniq
  end

  def available_pieces(player_pieces)
    king_location = locate_piece(turn.color, 'King')

    if king_in_check?
      attacking_pieces_locations = attacking_pieces_locations(king_location)

      available_pieces = unchecking_pieces(attacking_pieces_locations, king_location, player_pieces)
    else
      available_pieces = player_pieces.select do |space|
        piece = game_board.board[space].value
        piece.legal_moves.any?
      end
      available_pieces -= unmovable_protecting_pieces(king_location)
    end

    available_pieces.uniq
  end

  def unmovable_protecting_pieces(king_location)
    protecting_pieces = protecting_pieces_locations(king_location)

    protecting_pieces.delete_if do |protecting_piece, v|
      piece = game_board.board[protecting_piece].value

      piece.legal_moves.include?(v[:attacker])
    end

    protecting_pieces.keys
  end

  def protecting_pieces_locations(king_location)
    king = game_board.board[king_location].value
    opponent_color = king.color == 'white' ? 'black' : 'white'
    opponent_pieces = locate_player_pieces(opponent_color)
    player_pieces = locate_player_pieces(king.color)
    protecting_pieces = {}

    opponent_pieces.each do |opponent_location|
      opponent_piece = game_board.board[opponent_location].value
      next if single_move_piece?(opponent_piece)
      next unless piece_can_capture?(opponent_location)

      protecting_pieces[find_protecting_pieces(opponent_location)] = {
        attacker: opponent_location
      }
    end

    protecting_pieces.delete_if { |k, _v| k == nil }
  end

  def find_protecting_pieces(location)
    piece = game_board.board[location].value
    protecting_pieces = []

    piece.movement_directions.each do |direction|
      tmp = location
      pieces_encountered = 0

      loop do
        prev = tmp
        tmp = traverse(tmp, direction)

        break if tmp.nil? || pieces_encountered > 1

        current_piece = game_board.board[tmp].value

        next if current_piece == ' '
        break if current_piece.color == piece.color

        pieces_encountered += 1

        protecting_pieces << prev if pieces_encountered == 2 && current_piece.type == 'King'
      end
    end

    protecting_pieces[0]
  end

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
      coordinates[0] < 0 ||
      coordinates[1] < 1
  end

  def piece_can_capture?(piece_location)
    piece = game_board.board[piece_location].value
    piece.legal_moves.any? do |legal_move|
      space_occupied?(legal_move)
    end
  end

  def unchecking_pieces(attacking_pieces_locations, king_location, player_pieces)
    king = game_board.board[king_location].value
    check_blocking_pieces = check_blocking_pieces(king_location, player_pieces, attacking_pieces_locations)

    if attacking_pieces_locations.count == 1
      (player_pieces.select do |space|
        piece = game_board.board[space].value

        (piece.type == 'King' && piece.legal_moves.any?) ||
          piece.legal_moves.include?(attacking_pieces_locations[0])
      end) + check_blocking_pieces
    elsif king.legal_moves.any?
      [king_location]
    else
      []
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
    opponent_color = turn.color == 'white' ? 'black' : 'white'

    clear_legal_moves
    update_legal_moves(opponent_color)
    update_legal_moves(turn.color)
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

  def generate_knight_moves(piece, x_values, old_x, old_y)
    location = "#{x_values[old_x]}#{old_y}"

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

  def pawn_hop_used?(piece, origin, destination)
    return unless piece.type == 'Pawn'

    pawn_hop = [[0, 2], [0, -2]]
    difference = direction_of_travel(origin, destination)

    pawn_hop.include?(difference)
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

  def validate_input(input, valid_entries, hint)
    until valid_entries.include?(input)
      display_interface("Invalid input! #{hint}")
      input = gets.chomp
    end

    input
  end

  def draw?
    insufficient_material?
    stalemate?
  end

  def insufficient_material?
    white_piece_locations = locate_player_pieces('white')
    black_piece_locations = locate_player_pieces('black')

    white_pieces = white_piece_locations.map do |space|
      game_board.board[space].value
    end
    black_pieces = black_piece_locations.map do |space|
      game_board.board[space].value
    end

    king_vs_king?(white_pieces, black_pieces) ||
      king_bishop_vs_king?(white_pieces, black_pieces) ||
      king_bishop_vs_king?(black_pieces, white_pieces) ||
      king_knight_vs_king?(white_pieces, black_pieces) ||
      king_knight_vs_king?(black_pieces, white_pieces)
  end

  def king_vs_king?(white_pieces, black_pieces)
    white_pieces.count { |piece| piece.type == 'King' } == white_pieces.count &&
      black_pieces.count { |piece| piece.type == 'King' } == black_pieces.count
  end

  def king_bishop_vs_king?(player_pieces, opposite_player_pieces)
    (player_pieces.count { |piece| piece.type == 'King' } +
      player_pieces.count { |piece| piece.type == 'Bishop' } == player_pieces.count) &&
      (opposite_player_pieces.count { |piece| piece.type == 'King' } == opposite_player_pieces.count)
  end

  def king_knight_vs_king?(player_pieces, opposite_player_pieces)
    (player_pieces.count { |piece| piece.type == 'King' } +
      player_pieces.count { |piece| piece.type == 'Knight' } == player_pieces.count) &&
      (opposite_player_pieces.count { |piece| piece.type == 'King' } == opposite_player_pieces.count)
  end

  def stalemate?
    player_pieces = locate_player_pieces(turn.color)
    available_pieces = available_pieces(player_pieces)

    !king_in_check? && available_pieces.empty?
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

  def final_rank?(space)
    current_rank = space[1]
    last_rank = turn.color == 'white' ? '8' : '1'

    current_rank == last_rank
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

  def end_in_draw
    display_interface(end_message('draw'))
    exit
  end

  def resign_game
    opponent = turn.name == player_one.name ? player_two.name : player_one.name

    puts "#{turn.name} has resigned! #{opponent} wins!"
    exit
  end

  def game_over?
    checkmated?
  end

  def checkmated?
    player_pieces = locate_player_pieces(turn.color)
    update_legal_moves(turn.color)

    available_pieces = available_pieces(player_pieces)

    king_in_check? && available_pieces.empty?
  end
end
