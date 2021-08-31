# frozen_string_literal: true

class Pawn
  attr_accessor :legal_moves, :moved
  attr_reader :type, :color, :movement_directions, :capturing_moves

  def initialize(color)
    @type = 'Pawn'
    @color = color
    @legal_moves = []
    @movement_directions = [[0, 1]]
    @capturing_moves = [[1, 1], [-1, 1]]
    @moved = false
  end
end
