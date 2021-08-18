# frozen_string_literal: true

class Pawn
  attr_reader :type

  def initialize(color)
    @color = color
    @legal_moves = nil
    @movement_directions = [[0, 1]]
    @moved = false
  end
end
