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
    , windowSize : ( Int, Int )
    }


type alias KeysDown =
    { w : Bool, a : Bool, s : Bool, d : Bool }


bpm : Model -> Float
bpm model =
    80 + ((min model.progress 1) * 230)


sf : Model -> Float
sf model =
    5 - ((min model.progress 1) * 4.5)


tetrisSpeed : Model -> Float
tetrisSpeed model =
    0.02 + (model.progress * 0.2)


tetrisTicks : Model -> Int
tetrisTicks model =
    round (1 / (tetrisSpeed model))


tetrisControlsActivated : Model -> Bool
tetrisControlsActivated model =
    model.progress > 0.6


jumpSize : Model -> Float
jumpSize model =
    20 + (10 * model.progress)
