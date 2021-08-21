# frozen_string_literal: true

class Queen
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

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
