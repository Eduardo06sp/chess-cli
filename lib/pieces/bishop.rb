# frozen_string_literal: true

class Bishop
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions, :id

  def initialize(color, id)
    @type = 'Bishop'
    @id = id
    @color = color
    @legal_moves = []
    @movement_directions = [
      [1, 1],
      [1, -1],
      [-1, -1],
      [-1, 1]
    ]
  end
end
