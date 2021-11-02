# frozen_string_literal: true

class Rook
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

  def initialize(color, id)
    @type = 'Rook'
    @id = id
    @color = color
    @moved = false
    @legal_moves = []
    @movement_directions = [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ]
  end
end
