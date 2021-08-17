# frozen_string_literal: true

class King
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
      [-1, 1]
    ]
    @moved = false
    @in_check = false
    @mated = false
  end
end
