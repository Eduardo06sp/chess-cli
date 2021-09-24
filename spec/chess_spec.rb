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
        expect(pawn_moves).to eq(%w[c3 c4])
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
        new_rook_location = 'd4'

        new_game.game_board.move_piece(rook, 'a1', new_rook_location)
        new_game.generate_legal_moves(new_rook_location)

        rook_moves = rook.legal_moves
        expect(rook_moves).to eq(%w[d5 d6 d7 e4 f4 g4 h4 d3 c4 b4 a4])
      end

      it 'properly updates c1 Bishop legal_moves if moved to d4' do
        bishop = new_game.game_board.board['c1'].value
        new_bishop_location = 'd4'

        new_game.game_board.move_piece(bishop, 'c1', new_bishop_location)
        new_game.generate_legal_moves(new_bishop_location)

        bishop_moves = bishop.legal_moves
        expect(bishop_moves).to eq(%w[e5 f6 g7 e3 c3 c5 b6 a7])
      end

      it 'properly updates d1 Queen legal_moves if moved to d4' do
        queen = new_game.game_board.board['d1'].value
        new_queen_location = 'd4'

        new_game.game_board.move_piece(queen, 'd1', new_queen_location)
        new_game.generate_legal_moves(new_queen_location)

        queen_moves = queen.legal_moves
        expect(queen_moves).to eq(%w[d5 d6 d7
                                     e5 f6 g7
                                     e4 f4 g4
                                     h4 e3 d3
                                     c3 c4 b4
                                     a4 c5 b6
                                     a7])
      end

      it 'properly updates e1 King legal_moves if moved to d4' do
        king = new_game.game_board.board['e1'].value
        new_king_location = 'd4'

        new_game.game_board.move_piece(king, 'e1', new_king_location)
        new_game.generate_legal_moves(new_king_location)

        king_moves = king.legal_moves
        expect(king_moves).to eq(%w[d5 e5 e4 e3
                                    d3 c3 c4 c5])
      end

      it 'prevents b2 Pawn double hop if b3 Pawn present' do
        pawn = new_game.game_board.board['b2'].value
        enemy_pawn = new_game.game_board.board['b7'].value

        new_game.game_board.move_piece(enemy_pawn, 'b7', 'b3')
        new_game.generate_legal_moves('b2')
        new_game.generate_legal_moves('b3')

        pawn_moves = pawn.legal_moves
        expect(pawn_moves).to eq(%w[])
      end
    end
  end

  describe '#protecting_pieces' do
    context 'when re-arranged enemy pieces attack e1 King' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces
      end

      it 'returns d2 if a5 enemy Queen present' do
        queen = new_game.game_board.board['d8'].value
        king_location = 'e1'

        new_game.game_board.move_piece(queen, 'd8', 'a5')
        new_game.generate_legal_moves('a5')

        protecting_pieces = new_game.protecting_pieces_locations(king_location)
        expect(protecting_pieces).to eq(['d2'])
      end

      it 'returns d2 and f2 if a5 Queen and h4 Bishop present' do
        queen = new_game.game_board.board['d8'].value
        bishop = new_game.game_board.board['f8'].value
        king_location = 'e1'

        new_game.game_board.move_piece(queen, 'd8', 'a5')
        new_game.game_board.move_piece(bishop, 'f8', 'h4')
        new_game.generate_legal_moves('a5')
        new_game.generate_legal_moves('h4')

        protecting_pieces = new_game.protecting_pieces_locations(king_location)
        expect(protecting_pieces).to eq(%w[d2 f2])
      end

      it 'returns d2, e2 and f2 if a5 Queen, e6 Rook and h4 Bishop present' do
        queen = new_game.game_board.board['d8'].value
        rook = new_game.game_board.board['h8'].value
        bishop = new_game.game_board.board['f8'].value
        king_location = 'e1'

        new_game.game_board.move_piece(queen, 'd8', 'a5')
        new_game.game_board.move_piece(rook, 'h8', 'e6')
        new_game.game_board.move_piece(bishop, 'f8', 'h4')
        new_game.generate_legal_moves('a5')
        new_game.generate_legal_moves('e6')
        new_game.generate_legal_moves('h4')

        protecting_pieces = new_game.protecting_pieces_locations(king_location)
        expect(protecting_pieces).to eq(%w[d2 e2 f2])
      end

      it 'returns nothing when c3 and d2 Pawns simultaneously shield e1 King from a5 Queen' do
        queen = new_game.game_board.board['d8'].value
        pawn = new_game.game_board.board['c2'].value
        king_location = 'e1'

        new_game.game_board.move_piece(queen, 'd8', 'a5')
        new_game.game_board.move_piece(pawn, 'c2', 'c3')
        new_game.generate_legal_moves('a5')

        protecting_pieces = new_game.protecting_pieces_locations(king_location)
        expect(protecting_pieces).to eq(%w[])
      end
    end
  end

  describe '#attacking_pieces_locations' do
    context 'when e1 King is moved to f4 and enemy pieces are moved to attacking positions' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces

        king = new_game.game_board.board['e1'].value
        new_game.game_board.move_piece(king, 'e1', 'f4')
      end

      it 'adds a4 if Queen present' do
        queen = new_game.game_board.board['d8'].value
        king_location = 'f4'

        new_game.game_board.move_piece(queen, 'd8', 'a4')
        new_game.generate_legal_moves('a4')

        attacking_pieces = new_game.attacking_pieces_locations(king_location)
        expect(attacking_pieces).to eq(['a4'])
      end

      it 'adds e6 if Knight present' do
        knight = new_game.game_board.board['g8'].value
        king_location = 'f4'

        new_game.game_board.move_piece(knight, 'g8', 'e6')
        new_game.generate_legal_moves('e6')

        attacking_pieces = new_game.attacking_pieces_locations(king_location)
        expect(attacking_pieces).to eq(['e6'])
      end

      it 'adds e5 if Pawn present' do
        pawn = new_game.game_board.board['e7'].value
        king_location = 'f4'

        new_game.game_board.move_piece(pawn, 'e7', 'e5')
        new_game.generate_legal_moves('e5')

        attacking_pieces = new_game.attacking_pieces_locations(king_location)
        expect(attacking_pieces).to eq(['e5'])
      end

      it 'adds e5 and h5 if Pawn and Knight present' do
        pawn = new_game.game_board.board['e7'].value
        knight = new_game.game_board.board['g8'].value
        king_location = 'f4'

        new_game.game_board.move_piece(pawn, 'e7', 'e5')
        new_game.game_board.move_piece(knight, 'g8', 'h5')
        new_game.generate_legal_moves('e5')
        new_game.generate_legal_moves('h5')

        attacking_pieces = new_game.attacking_pieces_locations(king_location)
        expect(attacking_pieces).to eq(['e5', 'h5'])
      end
    end
  end

  describe '#directions_under_attack' do
    context 'when e1 King is moved to c4 and opponent pieces attack it' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces

        king = new_game.game_board.board['e1'].value
        new_game.game_board.move_piece(king, 'e1', 'c4')
        new_game.generate_legal_moves('c4')
      end

      it 'adds d5 if Bishop is on e6' do
        bishop = new_game.game_board.board['f8'].value
        king_location = 'c4'

        new_game.game_board.move_piece(bishop, 'f8', 'e6')
        new_game.generate_legal_moves('e6')

        directions_under_attack = new_game.directions_under_attack(king_location)
        expect(directions_under_attack).to eq(['d5'])
      end

      it 'adds c5 and d4 if c6 Rook and h4 Queen present' do
        rook = new_game.game_board.board['a8'].value
        queen = new_game.game_board.board['d8'].value
        king_location = 'c4'

        new_game.game_board.move_piece(rook, 'a8', 'c6')
        new_game.game_board.move_piece(queen, 'd8', 'h4')
        new_game.generate_legal_moves('c6')
        new_game.generate_legal_moves('h4')

        directions_under_attack = new_game.directions_under_attack(king_location)
        expect(directions_under_attack).to eq(%w[c5 d4])
      end
    end
  end

  describe '#moves_under_attack' do
    context 'when e1 King is moved to f5 and specified opponent pieces attack it' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces

        king = new_game.game_board.board['e1'].value
        new_game.game_board.move_piece(king, 'e1', 'f5')
        new_game.generate_legal_moves('f5')
      end

      it 'adds e5 if Queen present in a5' do
        queen = new_game.game_board.board['d8'].value
        king_location = 'f5'

        new_game.game_board.move_piece(queen, 'd8', 'a5')
        new_game.generate_legal_moves('a5')

        moves_under_attack = new_game.moves_under_attack(king_location)
        expect(moves_under_attack).to eq(['e5'])
      end

      it 'adds e4 and e5 if b5 Rook and d3 Bishop present' do
        rook = new_game.game_board.board['a8'].value
        bishop = new_game.game_board.board['c8'].value
        king_location = 'f5'

        new_game.game_board.move_piece(rook, 'a8', 'b5')
        new_game.game_board.move_piece(bishop, 'c8', 'd3')
        new_game.generate_legal_moves('b5')
        new_game.generate_legal_moves('d3')

        moves_under_attack = new_game.moves_under_attack(king_location)
        expect(moves_under_attack).to eq(%w[e5 e4])
      end
    end
  end

  describe '#available_pieces' do
    context 'when e1 King is moved to d4 and specified pieces rearranged' do
      before do
        allow(player_one).to receive(:color).and_return('white')
        allow(player_two).to receive(:color).and_return('black')
        new_game.add_initial_pieces

        king = new_game.game_board.board['e1'].value
        new_game.game_board.move_piece(king, 'e1', 'd4')
        new_game.generate_legal_moves('d4')
      end

      it 'returns pieces with available moves if King not in check' do
        new_game.update_legal_moves('white')

        white_pieces = new_game.locate_player_pieces('white')
        available_pieces = new_game.available_pieces(white_pieces)


        expect(available_pieces).to eq(%w[a2 b1 b2
                                          c2 d1 d2
                                          d4 e2 f2
                                          g1 g2 h2])
      end

      it 'returns King location (d4) if e5 Pawn attacks it' do
        pawn = new_game.game_board.board['e7'].value
        new_game.game_board.move_piece(pawn, 'e7', 'e5')
        new_game.generate_legal_moves('e5')

        white_pieces = new_game.locate_player_pieces('white')
        available_pieces = new_game.available_pieces(white_pieces)
        new_game.update_legal_moves('white')

        expect(available_pieces).to eq(%w[d4])
      end

      it 'returns d4 and e3 if e5 Pawn attacks d4 King with e3 Rook present' do
        pawn = new_game.game_board.board['e7'].value
        new_game.game_board.move_piece(pawn, 'e7', 'e5')
        new_game.generate_legal_moves('e5')

        rook = new_game.game_board.board['h1'].value
        new_game.game_board.move_piece(rook, 'h1', 'e3')
        new_game.generate_legal_moves('e3')

        white_pieces = new_game.locate_player_pieces('white')
        available_pieces = new_game.available_pieces(white_pieces)
        new_game.update_legal_moves('white')

        expect(available_pieces).to eq(%w[d4 e3])
      end

      it 'returns d4, e2, f2 and g2 if h4 Queen attacks d4 King' do
        queen = new_game.game_board.board['d8'].value
        new_game.game_board.move_piece(queen, 'd8', 'h4')
        new_game.generate_legal_moves('h4')

        new_game.reset_legal_moves('white')
        new_game.update_legal_moves('white')

        white_pieces = new_game.locate_player_pieces('white')
        available_pieces = new_game.available_pieces(white_pieces)

        expect(available_pieces).to eq(%w[d4 e2 f2 g2])
      end

      it 'returns d4 if h4 Queen and b6 Bishop attack d4 King' do
        queen = new_game.game_board.board['d8'].value
        bishop = new_game.game_board.board['c8'].value
        new_game.game_board.move_piece(queen, 'd8', 'h4')
        new_game.game_board.move_piece(queen, 'c8', 'b6')
        new_game.generate_legal_moves('h4')
        new_game.generate_legal_moves('b6')

        new_game.reset_legal_moves('white')
        new_game.update_legal_moves('white')

        white_pieces = new_game.locate_player_pieces('white')
        available_pieces = new_game.available_pieces(white_pieces)

        expect(available_pieces).to eq(%w[d4])
      end
    end
  end

  describe '#available_moves' do
    before do
      allow(player_one).to receive(:color).and_return('white')
      allow(player_two).to receive(:color).and_return('black')
      new_game.add_initial_pieces

      king = new_game.game_board.board['e1'].value
      new_game.game_board.move_piece(king, 'e1', 'd4')
    end

    context 'when e1 King is moved to d4 and not in check' do
      it 'returns h3 and h4 if h2 Pawn is selected' do
        new_game.update_legal_moves('white')
        available_moves = new_game.available_moves('h2')

        expect(available_moves).to eq(%w[h3 h4])
      end
    end

    context 'when e1 King is moved to d4 and specified pieces rearranged' do
      it 'returns c5 if h5 Rook selected when c5 Pawn attacks d4 King' do
        pawn = new_game.game_board.board['c7'].value
        new_game.game_board.move_piece(pawn, 'c7', 'c5')
        new_game.generate_legal_moves('c5')

        rook = new_game.game_board.board['h1'].value
        new_game.game_board.move_piece(rook, 'h1', 'h5')

        new_game.update_legal_moves('white')
        available_moves = new_game.available_moves('h5')

        expect(available_moves).to eq(%w[c5])
      end

      it 'returns e5 if g3 Bishop selected when f6 Queen attacks d4 King' do
        queen = new_game.game_board.board['d8'].value
        new_game.game_board.move_piece(queen, 'd8', 'f6')
        new_game.generate_legal_moves('f6')

        bishop = new_game.game_board.board['f1'].value
        new_game.game_board.move_piece(bishop, 'f1', 'g3')

        new_game.update_legal_moves('white')
        available_moves = new_game.available_moves('g3')

        expect(available_moves).to eq(%w[e5])
      end
    end

    it 'returns d2 if b1 Knight selected when d2 Queen attacks e2 King' do
      king = new_game.game_board.board['d4'].value
      new_game.game_board.move_piece(king, 'd4', 'e2')

      queen = new_game.game_board.board['d8'].value
      new_game.game_board.move_piece(queen, 'd8', 'd2')
      new_game.generate_legal_moves('d2')

      new_game.update_legal_moves('white')
      available_moves = new_game.available_moves('b1')

      expect(available_moves).to eq(%w[d2])
    end

    it 'returns f1 if g2 Queen selected when f1 Rook attacks g1 King and f2 space clear' do
      new_game.game_board.clear_space('f2')

      rook = new_game.game_board.board['a8'].value
      new_game.game_board.move_piece(rook, 'a8', 'f1')

      queen = new_game.game_board.board['d1'].value
      new_game.game_board.move_piece(queen, 'd1', 'g2')

      king = new_game.game_board.board['d4'].value
      new_game.game_board.move_piece(king, 'd4', 'g1')

      new_game.refresh_legal_moves
      available_moves = new_game.available_moves('g2')

      expect(available_moves).to eq(%w[f1])
    end
  end
end
