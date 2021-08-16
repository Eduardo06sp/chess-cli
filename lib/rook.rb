# frozen_string_literal: true

class Rook
  def initialize(color)
    @color = color
    @moved = false
    @legal_moves = nil
  end
end
