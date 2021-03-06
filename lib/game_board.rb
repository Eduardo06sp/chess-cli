# frozen_string_literal: true

require_relative 'cell'

class GameBoard
  attr_accessor :board

  def initialize
    @board = create_board
  end

  def create_board
    x_axis = ('a'..'h').to_a
    y_axis = (1..8).to_a
    board = {}

    x_axis.each do |letter|
      y_axis.each { |num| board["#{letter}#{num}"] = Cell.new }
    end

    board
  end

  def add_piece(piece, location)
    board[location].value = piece
  end

  def clear_space(location)
    board[location].value = ' '
  end

  def move_piece(piece, origin, destination)
    clear_space(origin)
    add_piece(piece, destination)
  end
end
