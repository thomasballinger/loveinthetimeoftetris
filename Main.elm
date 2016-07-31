module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (div, button, text, br, node)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)
import StoryView exposing (storyView)
import StoryView exposing (Directional(..))
import Tetris exposing (divGrid, exampleBoard)


main =
    beginnerProgram { model = initialWorld, view = view, update = update }


view model =
    div []
        [ css "http://localhost:8080/style.css"
        , js "http://localhost:8080/script.js"
        , button [ onClick Decrement ] [ text "-" ]
        , button [ onClick Increment ] [ text "+" ]
        , storyView model
        , tetrisView model.tetris
        ]


css path =
    node "link" [ rel "stylesheet", href path ] []


js path =
    node "script" [ src path ] []


tetrisView tetris =
    div [ class "board" ] (divGrid tetris)


initialWorld =
    { tetris = exampleBoard, player = { x = 50, y = 13, dir = Left, dx = 0, dy = 0 }, sf = 1 }



--if out of range, it's a wall


type Msg
    = Increment
    | Decrement


update msg model =
    case msg of
        Increment ->
            { model | sf = model.sf * 1.2 }

        Decrement ->
            { model | sf = model.sf * 0.75 }
