# frozen_string_literal: true

class Bishop
  attr_reader :type, :color, :movement_directions

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
