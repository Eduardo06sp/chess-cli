# Chess (CLI)
A 2-player version of Chess played in the terminal and integrating special rules (e.g. en passant and castling).

## Installing / Getting Started
> Prerequisites:
>
> * Ruby >= 2.7.2 (may work on older versions)

```console
git clone https://github.com/Eduardo06sp/chess-cli.git
cd chess-cli/
ruby lib/main.rb
```

You will then be prompted to set up the game and the game will start.
Input game board locations to make piece selections / moves (e.g. `a4`).

## Features
Core Features:
* Capturing
* Checking
  * Prevent any move/capture from putting own King into check
* Save / load
  * Limit: 5 slots

Game-ending Rules:
* Checkmate
* Insufficient material
  * King & Bishop vs. King
  * King & Knight vs. King
* Stalemate
* Resignation

Special Rules:
* Pawn hop/double-move
* Castling
  * King and Queen side
* En passant
* Promotion

Certain official rules of Chess have not been implemented.
They are as follows:
* Timer
* User-initiated draws
  * Mutual agreement
  * 3-fold repetition
  * 50-move rule
* Automatic draws
  * 5-fold repitition
  * 75-move rule

## Usage
Chess is a complex game with a special set of rules.
[Here is an excellent guide to learn more about how to play Chess.](https://www.chess.com/learn-how-to-play-chess) Please note that the article mentions user-initiated draws (draw by agreement, 3-fold repitition & 50-move rule), features which are not implemented in this version of Chess.

### Starting a new game
Ensure you are inside the `chess-cli` folder.
Then run `main.rb`.
```console
ruby lib/main.rb
```

Type `new` to start a new game.
Enter a name for player one, or simply press enter (without any input) to use the default (Player 1).
Enter a color (`black` or `white`) or just press enter to use "white".
Enter a name for player two, or press enter to use the default (Player 2).

### Selecting & moving pieces
Ranks (rows 1-8) and files (columns A-H) are used to specify locations on the board.
To move a2 Pawn to a3, select the a2 Pawn upon being prompted:
```console
a2
```

Then, you will be asked to make a move:
```console
a3
```

Then it is the other player's turn. You will continue until someone wins or a draw occurs.

### Saving/loading
#### Saving
To save the current state of the board, it must take place at the initial round prompt.
There is a message indicating that you may save the game.
To save:
```console
save
```

You will be prompted to enter a name or overwrite an existing save.
Enter a name.
You will get a confirmation once it successfully saves the game.

You may continue to play afterwards.
#### Loading
You may load a game when first launching the game.
In the initial game prompt, type:
```console
load
```

You will be prompted to select a slot number (1-5).
To select the first save, simply type:
```console
1
```

### Running RSpec tests
> Prerequisites:
>
> * Ruby >= 2.7.2 (may work on older versions)
> * RSpec >= 3.10 (may work on older versions)

From within `chess-cli` folder, run:
```console
rspec spec/game_board_spec.rb
rspec spec/chess_spec.rb
```
