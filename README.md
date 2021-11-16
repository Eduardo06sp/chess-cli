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
