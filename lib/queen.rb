# frozen_string_literal: true

class Queen
  def initialize(color)
    @color = color
    @legal_moves = nil
    @movement_directions = [
      [0, 1],
      [1, 1],
      [1, 0],
      [1, -1],
      [0, -1],
      [-1, -1],
      [-1, 0],
      [1, -1]
    ]
  end
end
