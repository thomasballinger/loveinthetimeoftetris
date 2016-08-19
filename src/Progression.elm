port module Progression exposing (..)

import Tetris exposing (TetrisState)
import Entity exposing (Movable, Drawable)
import Time


type alias Model =
    { tetris : TetrisState
    , player : Movable (Drawable {})
    , others : List (Movable (Drawable {}))
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


zoomActivated : Model -> Bool
zoomActivated model =
    model.progress > 0.98


jumpSize : Model -> Float
jumpSize model =
    20 + (10 * model.progress)


advance : Model -> Model
advance model =
    let
        desired =
            (model.progress + 0.00025)

        actual =
            if (desired > 0.99999999) then
                0.9997
                -- Hack to prevent from gif
                -- from getting stuck in first frame
                -- this is probably a bug with whatever
                -- in Elm Graphics loads gifs
                -- unfortunately it causes flicker, not sure
                -- which is worse.
            else
                desired
    in
        { model | progress = actual }
