# frozen_string_literal: true

class Knight
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions, :id

  def initialize(color, id)
    @type = 'Knight'
    @id = id
    @color = color
    @legal_moves = []
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
