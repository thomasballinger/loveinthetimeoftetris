module Main exposing (..)

import Html.Attributes exposing (class, rel, src, href)
import Html exposing (div, button, text, br, node, Html)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import Time
import StoryView exposing (storyView, tetrisBlocksWithWalls)
import Entity exposing (..)
import Tetris exposing (divGrid, exampleTetrisState, TetrisState, spots)
import Keyboard


type alias Model =
    { tetris : TetrisState
    , player : Movable (Standable (Collidable (Drawable {})))
    , sf : Float
    , lastTick : Time.Time
    , keysDown : KeysDown
    }


type alias KeysDown =
    { w : Bool, a : Bool, s : Bool, d : Bool }


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialWorld, Cmd.none )


initialWorld =
    { tetris = exampleTetrisState
    , player = initialPlayer 50 13
    , sf = 1
    , lastTick = 0
    , keysDown = { w = False, a = False, s = False, d = False }
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDownMsg
        , Keyboard.ups KeyUpMsg
        , Time.every 16 Tick
        ]


view : Model -> Html Msg
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
    div [ class "board" ] (divGrid (spots tetris))



---if out of range, it's a wall


type Msg
    = Increment
    | Decrement
    | KeyDownMsg Keyboard.KeyCode
    | KeyUpMsg Keyboard.KeyCode
    | Tick Time.Time


keypressedPlayer keysDown dt player =
    let
        afterJump =
            if keysDown.w && player.onGround then
                { player | dy = player.dy + 30, onGround = False }
            else
                player

        afterLR =
            case afterJump.onGround of
                True ->
                    if keysDown.a then
                        { afterJump
                            | dir = Left
                            , dx = max (afterJump.dx - 2 * dt) (-10)
                            , state = Running
                        }
                    else if keysDown.d then
                        { afterJump
                            | dir = Right
                            , dx = min (afterJump.dx + 2 * dt) 10
                            , state = Running
                        }
                    else
                        afterJump

                False ->
                    if keysDown.a then
                        { afterJump
                            | dir = Left
                            , dx = max (afterJump.dx - 1 * dt) (-10)
                        }
                    else if keysDown.d then
                        { afterJump
                            | dir = Right
                            , dx = min (afterJump.dx + 1 * dt) 10
                        }
                    else
                        afterJump
    in
        afterLR


slowedPlayer dt player =
    if (player.onGround) then
        if (abs player.dx) < 0.2 then
            { player | dx = 0, state = Standing }
        else
            let
                μ =
                    0.7
            in
                { player | dx = player.dx * μ ^ dt }
    else
        let
            μ =
                0.9
        in
            { player | dx = player.dx * μ ^ dt }


blockUpdate : TetrisState -> Collidable (Movable (Standable a)) -> Collidable (Movable (Standable a))
blockUpdate tetris entity =
    let
        blocks =
            tetrisBlocksWithWalls (spots tetris)

        collision =
            wallCollision blocks entity
    in
        wallAlter entity collision


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel =
            case msg of
                Increment ->
                    { model | sf = model.sf * 1.25 }

                Decrement ->
                    { model | sf = model.sf * 0.8 }

                KeyDownMsg code ->
                    let
                        keysDown =
                            model.keysDown

                        newKeysDown =
                            case Char.fromCode code of
                                'W' ->
                                    { keysDown | w = True }

                                'A' ->
                                    { keysDown | a = True }

                                'S' ->
                                    { keysDown | s = True }

                                'D' ->
                                    { keysDown | d = True }

                                _ ->
                                    keysDown
                    in
                        { model | keysDown = newKeysDown }

                KeyUpMsg code ->
                    let
                        keysDown =
                            model.keysDown

                        newKeysDown =
                            case Char.fromCode code of
                                'W' ->
                                    { keysDown | w = False }

                                'A' ->
                                    { keysDown | a = False }

                                'S' ->
                                    { keysDown | s = False }

                                'D' ->
                                    { keysDown | d = False }

                                _ ->
                                    keysDown
                    in
                        { model | keysDown = newKeysDown }

                Tick time ->
                    if model.lastTick == 0 then
                        { model | lastTick = time }
                    else
                        let
                            delta =
                                time - model.lastTick
                        in
                            { model
                                | player =
                                    model.player
                                        |> slowedPlayer 0.5
                                        |> keypressedPlayer model.keysDown 0.5
                                        |> step 0.5
                                        |> gravity 0.5
                                        |> blockUpdate model.tetris
                            }
    in
        ( newModel, Cmd.none )
