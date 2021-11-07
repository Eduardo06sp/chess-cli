# frozen_string_literal: true

class Pawn
  attr_accessor :legal_moves, :en_passant_moves, :double_hop_used, :moves, :moved
  attr_reader :type, :color, :movement_directions, :capturing_moves, :id

  def initialize(color)
    @type = 'Pawn'
    @id = 0
    @color = color
    @legal_moves = []
    @en_passant_moves = []
    @movement_directions = generate_movement_direction
    @capturing_moves = generate_capturing_moves
    @double_hop_used = false
    @moves = 0
    @moved = false
  end

  def generate_movement_direction
    if color == 'white'
      [[0, 1]]
    else
      [[0, -1]]
    end
  end

  def generate_capturing_moves
    if color == 'white'
      [[1, 1], [-1, 1]]
    else
      [[1, -1], [-1, -1]]
    end
  end
end
