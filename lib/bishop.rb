# frozen_string_literal: true

class Bishop
  def initialize(color)
    @type = 'Bishop'
    @color = color
    @legal_moves = nil
    @movement_directions = [
      [1, 1],
      [1, -1],
      [-1, -1],
      [-1, 1]
    ]
  end
end
