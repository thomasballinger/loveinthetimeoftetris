module TetrisAI exposing (desiredX)

import List
import Tetris exposing (..)
import Piece exposing (..)


desiredX : TetrisState -> Int
desiredX tetris =
    4
