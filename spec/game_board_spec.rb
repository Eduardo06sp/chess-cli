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
    it 'contains key a1' do
      valid_key = 'a1'
      board = new_board.instance_variable_get(:@board)
      expect(board.key?(valid_key)).to eq(true)
    end

    it 'contains key h8' do
      valid_key = 'h8'
      board = new_board.instance_variable_get(:@board)
      expect(board.key?(valid_key)).to eq(true)
    end

    it 'does not contain key g9' do
      invalid_key = 'g9'
      board = new_board.instance_variable_get(:@board)
      expect(board.key?(invalid_key)).to eq(false)
    end
  end

  describe '#add_piece' do
    it 'adds Rook to a5 when passed as arguments' do
      new_board.add_piece('Rook', 'a5')
      board = new_board.instance_variable_get(:@board)
      expect(board['a5'].value).to eq('Rook')
    end
  end

  describe '#clear_space' do
    it 'empties space h8 when previously occupied by Rook' do
      new_board.add_piece('Rook', 'h8')
      new_board.clear_space('h8')
      board = new_board.instance_variable_get(:@board)
      expect(board['h8'].value).to eq(' ')
    end
  end
end
