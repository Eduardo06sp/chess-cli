# frozen_string_literal: true

require_relative 'game_board'

class Chess
  def initialize(player_one, player_two)
    @player_one = player_one
    @player_two = player_two
    @game_board = GameBoard.new
  end

  def first_turn
  end
end
