# frozen_string_literal: true

class Knight
  attr_reader :type

  def initialize(color)
    @type = 'Knight'
    @color = color
    @legal_moves = nil
    @movement_directions = [
      [1, 2],
      [2, 1],
      [2, -1],
      [1, -2],
      [-1, -2],
      [-2, -1],
      [-2, 1],
      [-1, 2]
    ]
  end
end
