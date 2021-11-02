# frozen_string_literal: true

class Queen
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

  def initialize(color)
    @type = 'Queen'
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
  end
end
