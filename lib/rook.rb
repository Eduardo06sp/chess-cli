# frozen_string_literal: true

class Rook
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

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
