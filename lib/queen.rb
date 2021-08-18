# frozen_string_literal: true

class Queen
  attr_reader :type

  def initialize(color)
    @type = 'Queen'
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
