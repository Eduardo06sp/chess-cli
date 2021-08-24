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
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces
      end

      it 'updates legal moves for Queen-side white Knight properly' do
        knight_location = 'b1'
        knight = new_game.game_board.board[knight_location].value

        new_game.generate_legal_moves(knight_location)

        knight_moves = knight.legal_moves
        expect(knight_moves).to eq(%w[c3 a3])
      end

      it 'updates legal moves for c2 Pawn properly' do
        pawn_location = 'c2'
        pawn = new_game.game_board.board[pawn_location].value

        new_game.generate_legal_moves(pawn_location)

        pawn_moves = pawn.legal_moves
        expect(pawn_moves).to eq(%w[c3])
      end
    end

    context 'when initial board is set up and specified piece is moved anywhere' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces
      end
    end
  end
end
