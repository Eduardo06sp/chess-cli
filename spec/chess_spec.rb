# frozen_string_literal: true

require_relative '../lib/chess'
require_relative '../lib/player'

describe Chess do
  let(:player_one) { instance_double(Player) }
  let(:player_two) { instance_double(Player) }
  subject(:new_game) { Chess.new(player_one, player_two) }

  describe '#fill_king_rank' do
    before do
      allow(player_one).to receive(:color)
      allow(player_two).to receive(:color)
    end

    it 'adds white Queen to d1 with given arguments' do
      new_game.fill_king_rank('white', '1')
      game_board = new_game.instance_variable_get(:@game_board)
      expect(game_board.board['d1'].value.type).to eq('Queen')
    end

    it 'adds white Knight to b1 with given arguments' do
      new_game.fill_king_rank('white', '1')
      game_board = new_game.instance_variable_get(:@game_board)
      expect(game_board.board['b1'].value.type).to eq('Knight')
    end
  end

  describe '#fill_pawn_rank' do
    before do
      allow(player_one).to receive(:color)
      allow(player_two).to receive(:color)
    end

    it 'adds white Pawn to g2 with given arguments' do
      new_game.fill_pawn_rank('white', '2')
      game_board = new_game.instance_variable_get(:@game_board)
      expect(game_board.board['g2'].value.type).to eq('Pawn')
    end

    it 'adds white Pawn to h2 with given arguments' do
      new_game.fill_pawn_rank('white', '2')
      game_board = new_game.instance_variable_get(:@game_board)
      expect(game_board.board['h2'].value.type).to eq('Pawn')
    end
  end

  describe '#generate_legal_moves' do
    context 'when initial board is set up' do
    end
  end
end
