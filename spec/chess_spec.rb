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
        pawn_moves = pawn.legal_moves

        new_game.generate_legal_moves(pawn_location)

        expect(pawn_moves).to eq(%w[c3])
      end
    end

    context 'when initial board is set up and specified piece is moved anywhere' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces
      end

      it 'properly updates a1 Rook legal_moves if moved to d4' do
        rook = new_game.game_board.board['a1'].value
        rook_moves = rook.legal_moves
        new_rook_location = 'd4'

        new_game.game_board.move_piece(rook, 'a1', new_rook_location)
        new_game.generate_legal_moves(new_rook_location)

        expect(rook_moves).to eq(%w[d5 d6 d7 e4 f4 g4 h4 d3 c4 b4 a4])
      end

      it 'properly updates c1 Bishop legal_moves if moved to d4' do
        bishop = new_game.game_board.board['c1'].value
        bishop_moves = bishop.legal_moves
        new_bishop_location = 'd4'

        new_game.game_board.move_piece(bishop, 'c1', new_bishop_location)
        new_game.generate_legal_moves(new_bishop_location)

        expect(bishop_moves).to eq(%w[e5 f6 g7 e3 c3 c5 b6 a7])
      end

      it 'properly updates d1 Queen legal_moves if moved to d4' do
        queen = new_game.game_board.board['d1'].value
        queen_moves = queen.legal_moves
        new_queen_location = 'd4'

        new_game.game_board.move_piece(queen, 'd1', new_queen_location)
        new_game.generate_legal_moves(new_queen_location)

        expect(queen_moves).to eq(%w[d5 d6 d7
                                     e5 f6 g7
                                     e4 f4 g4 h4
                                     e3 d3 c3
                                     c4 b4 a4])
      end

      it 'properly updates e1 King legal_moves if moved to d4' do
        king = new_game.game_board.board['e1'].value
        king_moves = king.legal_moves
        new_king_location = 'd4'

        new_game.game_board.move_piece(king, 'e1', new_king_location)
        new_game.generate_legal_moves(new_king_location)

        expect(king_moves).to eq(%w[d5 e5 e4 e3
                                    d3 c3 c4 c5])
      end
    end
  end

  describe '#attacking_pieces_locations' do
    context 'when e1 King is moved to f4 and enemy pieces are moved to attacking positions' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces
      end
    end
  end
end
