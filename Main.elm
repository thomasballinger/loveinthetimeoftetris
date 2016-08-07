module Main exposing (..)

import Html.Attributes exposing (class, rel, src, href)
import Html exposing (div, button, text, br, node, Html)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import Time
import StoryView exposing (storyView, tetrisBlocksWithWalls)
import Entity exposing (..)
import Tetris exposing (divGrid, exampleBoard, TetrisState)
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
    { tetris = exampleBoard
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
        , Time.every 32 Tick
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
    div [ class "board" ] (divGrid tetris)



---if out of range, it's a wall


type Msg
    = Increment
    | Decrement
    | KeyDownMsg Keyboard.KeyCode
    | KeyUpMsg Keyboard.KeyCode
    | Tick Time.Time


keypressedPlayer keysDown player =
    let
        afterJump =
            if keysDown.w && player.state == Standing then
                { player | dy = player.dy + 10, state = Jumping }
            else
                player

        afterLR =
            if keysDown.a then
                { afterLR | dir = Left, dx = max (afterLR.dx - 1) (-10) }
            else if keysDown.d then
                { afterLR | dir = Right, dx = min (afterLR.dx + 1) 10 }
            else
                afterLR
    in
        afterLR


slowedPlayer player =
    if player.state == Standing then
        { player
            | dx =
                if (abs player.dx) < 0.1 then
                    0
                else
                    player.dx * 0.6
        }
    else
        player



-- Plan for transformations to entities:
-- * updates due to player inputs
-- * update positions based on dx, dy
-- * apply accelerations (friction, gravity, air resistance)
-- * n*m collisions: check if entities are standing
-- * n*n collisions: check entities against each other for damage
-- * draw


blockUpdate : TetrisState -> Collidable (Movable (Standable a)) -> Collidable (Movable (Standable a))
blockUpdate tetris entity =
    let
        blocks =
            tetrisBlocksWithWalls tetris

        collision =
            Debug.log "collision" (wallCollision blocks entity)
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
                                'w' ->
                                    { keysDown | w = True }

                                'a' ->
                                    { keysDown | a = True }

                                's' ->
                                    { keysDown | s = True }

                                'd' ->
                                    { keysDown | d = True }

                                _ ->
                                    keysDown
                    in
                        { model | keysDown = Debug.log "keys down" newKeysDown }

                KeyUpMsg code ->
                    let
                        keysDown =
                            model.keysDown

                        newKeysDown =
                            case Char.fromCode code of
                                'w' ->
                                    { keysDown | w = False }

                                'a' ->
                                    { keysDown | a = False }

                                's' ->
                                    { keysDown | s = False }

                                'd' ->
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
                                        |> slowedPlayer
                                        |> keypressedPlayer model.keysDown
                                        |> step 1
                                        |> gravity 1
                                        |> blockUpdate model.tetris
                            }
    in
        ( newModel, Cmd.none )
