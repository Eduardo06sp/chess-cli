# frozen_string_literal: true

module PieceAvailability
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
    protecting_pieces = {}

    opponent_pieces.each do |opponent_location|
      opponent_piece = game_board.board[opponent_location].value
      next if single_move_piece?(opponent_piece)
      next unless piece_can_capture?(opponent_location)

      protecting_pieces[find_protecting_pieces(opponent_location)] = {
        attacker: opponent_location
      }
    end

    protecting_pieces.delete_if { |k, _v| k.nil? }
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
end
