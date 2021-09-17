# frozen_string_literal: true

module TerminalInterface
  private

  def display_title
    puts <<~HEREDOC
      ---------------------------------------
      ---------------- CHESS ----------------
      ---------------------------------------
    HEREDOC
  end

  def display_board
    puts <<-HEREDOC
            A B C D E F G H
          8 \e[47m#{val('a8')} \e[45m#{val('b8')} \e[47m#{val('c8')} \e[45m#{val('d8')} \e[47m#{val('e8')} \e[45m#{val('f8')} \e[47m#{val('g8')} \e[45m#{val('h8')} \e[0m 8
          7 \e[45m#{val('a7')} \e[47m#{val('b7')} \e[45m#{val('c7')} \e[47m#{val('d7')} \e[45m#{val('e7')} \e[47m#{val('f7')} \e[45m#{val('g7')} \e[47m#{val('h7')} \e[0m 7
          6 \e[47m#{val('a6')} \e[45m#{val('b6')} \e[47m#{val('c6')} \e[45m#{val('d6')} \e[47m#{val('e6')} \e[45m#{val('f6')} \e[47m#{val('g6')} \e[45m#{val('h6')} \e[0m 6
          5 \e[45m#{val('a5')} \e[47m#{val('b5')} \e[45m#{val('c5')} \e[47m#{val('d5')} \e[45m#{val('e5')} \e[47m#{val('f5')} \e[45m#{val('g5')} \e[47m#{val('h5')} \e[0m 5
          4 \e[47m#{val('a4')} \e[45m#{val('b4')} \e[47m#{val('c4')} \e[45m#{val('d4')} \e[47m#{val('e4')} \e[45m#{val('f4')} \e[47m#{val('g4')} \e[45m#{val('h4')} \e[0m 4
          3 \e[45m#{val('a3')} \e[47m#{val('b3')} \e[45m#{val('c3')} \e[47m#{val('d3')} \e[45m#{val('e3')} \e[47m#{val('f3')} \e[45m#{val('g3')} \e[47m#{val('h3')} \e[0m 3
          2 \e[47m#{val('a2')} \e[45m#{val('b2')} \e[47m#{val('c2')} \e[45m#{val('d2')} \e[47m#{val('e2')} \e[45m#{val('f2')} \e[47m#{val('g2')} \e[45m#{val('h2')} \e[0m 2
          1 \e[45m#{val('a1')} \e[47m#{val('b1')} \e[45m#{val('c1')} \e[47m#{val('d1')} \e[45m#{val('e1')} \e[47m#{val('f1')} \e[45m#{val('g1')} \e[47m#{val('h1')} \e[0m 1
            A B C D E F G H
    HEREDOC
  end

  def val(coordinate)
    space = game_board.board[coordinate].value
    return space if space == ' '

    piece = if space.color == 'white'
              {
                'Rook' => '♖',
                'Knight' => '♘',
                'Bishop' => '♗',
                'Queen' => '♕',
                'King' => '♔',
                'Pawn' => '♙'
              }
            else
              {
                'Rook' => '♜',
                'Knight' => '♞',
                'Bishop' => '♝',
                'Queen' => '♛',
                'King' => '♚',
                'Pawn' => '♟'
              }
            end

    piece[space.type]
  end

  def display_turn
    puts <<~HEREDOC
      ----------------------------------------
            #{turn.name}'s turn! (#{display_king(turn.color)} #{turn.color} pieces)
    HEREDOC
  end

  def display_king(color)
    color == 'white' ? '♔' : '♚'
  end

  def display_game_message(message)
    puts <<~HEREDOC
              #{message}
      ----------------------------------------
    HEREDOC
  end

  def display_interface(message)
    display_title
    display_board
    display_turn
    display_game_message(message)
  end
end
