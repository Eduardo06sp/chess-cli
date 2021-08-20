# frozen_string_literal: true

class King
  attr_reader :type, :color, :mated

  def initialize(color)
    @type = 'King'
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
