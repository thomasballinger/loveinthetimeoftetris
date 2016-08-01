module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (div, button, text, br, node)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import StoryView exposing (storyView)
import StoryView exposing (Directional(..))
import Tetris exposing (divGrid, exampleBoard)
import Keyboard


main =
    App.program
        { init = ( initialWorld, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions model =
    Keyboard.presses KeyMsg


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
    | KeyMsg Keyboard.KeyCode


keypressedPlayer player code =
    case Char.fromCode code of
        'w' ->
            { player | dy = player.dy + 1 }

        'a' ->
            { player | dir = Left, x = player.x - 10 }

        'd' ->
            { player | dir = Right, x = player.x + 10 }

        _ ->
            player


update msg model =
    let
        newModel =
            case msg of
                Increment ->
                    { model | sf = model.sf * 1.25 }

                Decrement ->
                    { model | sf = model.sf * 0.8 }

                KeyMsg code ->
                    { model | player = keypressedPlayer model.player code }
    in
        ( newModel, Cmd.none )
