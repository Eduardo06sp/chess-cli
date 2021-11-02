# frozen_string_literal: true

class Pawn
  attr_accessor :legal_moves, :moved
  attr_reader :type, :color, :movement_directions, :capturing_moves

  def initialize(color)
    @type = 'Pawn'
    @id = 0
    @color = color
    @legal_moves = []
    @movement_directions = generate_movement_direction
    @capturing_moves = generate_capturing_moves
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
