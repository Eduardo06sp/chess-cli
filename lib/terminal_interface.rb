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
    puts <<~HEREDOC
        A B C D E F G H
      8 \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[0m 8
      7 \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[0m 7
      6 \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[0m 6
      5 \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[0m 5
      4 \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[0m 4
      3 \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[0m 3
      2 \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[0m 2
      1 \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[45m  \e[47m  \e[0m 1
        A B C D E F G H
    HEREDOC
  end
end
