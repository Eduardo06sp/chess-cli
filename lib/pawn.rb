# frozen_string_literal: true

class Pawn
  attr_accessor :legal_moves, :moved
  attr_reader :type, :color, :movement_directions, :capturing_moves

  def initialize(color)
    @type = 'Pawn'
    @color = color
    @legal_moves = []
    @movement_directions = get_movement_direction
    @capturing_moves = [[1, 1], [-1, 1]]
    @moved = false
  end

  def get_movement_direction
    if color == 'white'
      [[0, 1]]
    else
      [[0, -1]]
    end
  end
end
