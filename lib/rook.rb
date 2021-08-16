# frozen_string_literal: true

class Rook
  def initialize(color)
    @color = color
    @moved = false
    @legal_moves = nil
    @movement_directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
  end
end
