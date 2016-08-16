port module Progression exposing (..)

import Tetris exposing (TetrisState)
import Entity exposing (Movable, Standable, Collidable, Drawable)
import Time


type alias Model =
    { tetris : TetrisState
    , player : Movable (Standable (Collidable (Drawable {})))
    , others : List (Movable (Standable (Collidable (Drawable {}))))
    , progress : Float
    , lastTick : Time.Time
    , keysDown : KeysDown
    }


type alias KeysDown =
    { w : Bool, a : Bool, s : Bool, d : Bool }


bpm model =
    60 + ((min model.progress 1) * 230)


sf model =
    5 - ((min model.progress 1) * 4.5)


tetrisSpeed model =
    0.05 + (model.progress * 0.2)


tetrisTicks model =
    round (1 / (tetrisSpeed model))


tetrisControlsActivated model =
    model.progress > 0.6


jumpSize model =
    22
