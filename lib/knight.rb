# frozen_string_literal: true

class Knight
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

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
