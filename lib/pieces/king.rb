# frozen_string_literal: true

class King
  attr_accessor :legal_moves, :moved
  attr_reader :type, :color, :movement_directions, :checkmated, :id

  def initialize(color)
    @type = 'King'
    @id = 0
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
