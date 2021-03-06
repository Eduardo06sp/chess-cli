# Chess (CLI)
![A screenshot showing the start of a new game](media/new_game_screenshot.png "New Chess Game")
> **Note:** If running the app locally, it is highly recommended that you increase your font size (this must be set by the user). If running the live version, it is not possible to increase font size at the time of writing.

A 2-player version of Chess played in the terminal and integrating special rules (e.g. en passant and castling).

[Click here to play a live version on Replit (click the big play button and wait for the script to execute).](https://replit.com/@Eduardo06sp/Chess-CLI?v=1)

## Table of Contents
* [General Information](#general-information)
* [Installing / Getting Started](#installing--getting-started)
* [Features](#features)
* [Usage](#usage)
  * [Special Rules](#special-rules)
  * [Saving / Loading](#savingloading)
  * [Running Tests](#running-rspec-tests)
* [Acknowledgements](#acknowledgements)
* [Reporting Issues / Feedback / Contact](#reporting-issuesfeedbackcontact)

## General Information
Chess is a 2-player game in which two players take turns moving pieces. Each piece may move in a unique manner, and the objective is to place the opponent's King into checkmate (i.e. trap them in a spot so they have nowhere to move).

This project was a significant undertaking as there are so many different components to the game. The goal was to keep methods and classes as modular as I could and take into account various edge-cases. Testing with RSpec was of vital importance, and minimizing bloated code was key to hunting down errors in the game.

Another significant challenge was using a git feature branch workflow. Creating branches when trying new features out helped me learn a lot about rebasing and merging branches. There were a lot of unique errors encountered in git, which helped me explore git features such as amending commits and solving merge conflicts with my built-in text editor (VIM).

To learn more about playing Chess, [click here for a guide.](https://www.chess.com/learn-how-to-play-chess)

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

### Special Rules
In Chess, there are various special rules such as:
* Pawn hop/double-move
* Castling
* En passant
* Promotion

For more information (and a simple explanation) of the special rules, refer to [the previously linked guide to Chess](https://www.chess.com/learn-how-to-play-chess#special-rules-chess).

#### Pawn hop/double-move
To Pawn hop (conditions permitting), simply type in the space located two spots away from the selected Pawn.

E.g. Pawn hopping from a2 to a4:
```console
a2
a4
```

#### Castling
To castle (conditions permitting), you may either:
1. Move the Rook to the space adjacent to the King
2. Move the King two spaces towards the Rook

The game will automatically move the Rook/King to their appropriate places.

#### En passant
To en passant (conditions permitting), simply type in the empty space the enemy Pawn hopped over.

The game will automatically capture/remove the enemy Pawn.

#### Promotion
To promote a Pawn, you will be prompted to upgrade your Pawn once you reach the final rank.
You may input any of the following, and your Pawn will be replaced with the selected piece type:
* Rook
* Knight
* Bishop
* Queen

The game will replace the promoted Pawn with your selection.

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

#### Overwriting
You will have to overwrite your saves if you try to exceed 5 saves, or if you choose this option when saving.
To overwrite, after selecting it or exceeding 5 saves, you will be prompted to select the save file number that will be overwritten.
To overwite the first save, type:
```console
1
```

Then you will be prompted to enter a name.
Enter a name.
You will see a message once the game succesfully saves.

You may continue to play.

### Resigning / Exiting
> If you are stuck for any reason, press `Ctrl + C` (depending on your system) to force close the app. See [Reporting Issues/Feedback](#reporting-issuesfeedbackcontact) to report it.

You may resign/exit in-game by typing any of the following during the inital round prompt:
```console
resign
exit
quit
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

## Acknowledgements
* [The Odin Project](https://www.theodinproject.com/home), my favorite, highly-recommended resource for learning full-stack web development
  * For providing this project idea ([see the instructions for this assignment here](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-programming/lessons/ruby-final-project))
  * For their kind, helpful Discord community
* [TextKool](https://textkool.com/en), an ASCII text-art generator (plus more!)
  * Used to display draw & checkmate text art

## Reporting Issues/Feedback/Contact
Bug reports are greatly appreciated. You may create a new issue with a description of the problem, and the steps leading up to it.

PRs are kindly appreciated. The project tries to adhere to Rubocop's default coding guidelines, but this is only a soft requirement.

You may also contact me at: eduardopelaez@pm.me
