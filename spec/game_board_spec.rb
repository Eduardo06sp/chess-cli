# frozen_string_literal: true

require_relative '../lib/game_board'

describe GameBoard do
  subject(:new_board) { GameBoard.new }

  describe '#create_board' do
    it 'returns a hash with 64 keys' do
      board = new_board.create_board
      board_keys = board.keys

      expect(board_keys.count).to eq(64)
    end
  end

  describe '@board' do
  end
end
