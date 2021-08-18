# frozen_string_literal: true

class Rook
  attr_reader :type

  def initialize(color)
    @type = 'Rook'
    @color = color
    @moved = false
    @legal_moves = nil
    @movement_directions = [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ]
  end
end
