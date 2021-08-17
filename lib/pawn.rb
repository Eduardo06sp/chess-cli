# frozen_string_literal: true

class Pawn
  def initialize(color)
    @color = color
    @legal_moves = nil
    @movement_directions = [[0, 1]]
    @moved = false
  end
end
