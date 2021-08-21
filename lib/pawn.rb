# frozen_string_literal: true

class Pawn
  attr_accessor :legal_moves
  attr_reader :type, :color, :movement_directions

  def initialize(color)
    @type = 'Pawn'
    @color = color
    @legal_moves = nil
    @movement_directions = [[0, 1]]
    @moved = false
  end
end
