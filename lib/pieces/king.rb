# frozen_string_literal: true

class King
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions, :checkmated

  def initialize(color)
    @type = 'King'
    @color = color
    @legal_moves = []
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
    @checkmated = false
  end
end
