module Main exposing (..)

import Html.Attributes exposing (class, rel, src, href)
import Html exposing (div, button, text, br, node, Html)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import Time
import StoryView exposing (storyView)
import Entity exposing (..)
import Others exposing (..)
import Tetris exposing (divGrid, exampleTetrisState, TetrisState, tetrisGrid, tetrisLeft, tetrisRight, tetrisDown, tetrisRotateLeft, tetrisRotateRight, tetrisBlocksWithWalls, moveWorks, pointAdd)
import Piece exposing (newPiece)
import TetrisAI exposing (desiredXAndRot)
import Keyboard
import Random


ticks : Float -> Int
ticks speed =
    round (1 / speed)


type alias Model =
    { tetris : TetrisState
    , player : Movable (Standable (Collidable (Drawable {})))
    , others : List (Movable (Standable (Collidable (Drawable {}))))
    , sf : Float
    , targetSF : Float
    , tetrisSpeed : Float
    , targetTetrisSpeed : Float
    , tetrisControlsActivated : Bool
    , jumpSize : Float
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
    , player =
        initialPlayer ( 50, 100 )
        --    , others = [ princess ( 100, 100 ) ]
    , others = []
    , sf = 4
    , targetSF = 0.3
    , tetrisSpeed = 0.01
    , targetTetrisSpeed = 0.5
    , tetrisControlsActivated = False
    , jumpSize = 22
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
        , storyView 800 600 model
          --        , tetrisView model.tetris
        ]


css path =
    node "link" [ rel "stylesheet", href path ] []


js path =
    node "script" [ src path ] []


tetrisView tetris =
    div [ class "board" ] (divGrid (tetrisGrid tetris))



---if out of range, it's a wall


type Msg
    = KeyDownMsg Keyboard.KeyCode
    | KeyUpMsg Keyboard.KeyCode
    | Tick Time.Time
    | NewPiece Int


keypressedPlayer keysDown dt jumpSize player =
    let
        afterJump =
            if keysDown.w && player.onGround then
                { player | dy = player.dy + jumpSize, onGround = False }
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


blockUpdate : Int -> Float -> TetrisState -> Collidable (Movable (Standable (Drawable a))) -> Collidable (Movable (Standable (Drawable a)))
blockUpdate ticksPerTetrisSquare dt tetris entity =
    let
        blocks =
            tetrisBlocksWithWalls ticksPerTetrisSquare dt tetris
    in
        doCollisions blocks entity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel =
            case msg of
                NewPiece i ->
                    { model | tetris = (withNewPiece i model.tetris) }

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

                        newTetris =
                            if model.tetrisControlsActivated then
                                case Char.fromCode code of
                                    'J' ->
                                        tetrisLeft model.tetris

                                    'L' ->
                                        tetrisRight model.tetris

                                    'K' ->
                                        tetrisDown model.tetris

                                    'U' ->
                                        tetrisRotateLeft model.tetris

                                    'I' ->
                                        tetrisRotateRight model.tetris

                                    'O' ->
                                        tetrisRotateRight model.tetris

                                    _ ->
                                        model.tetris
                            else
                                model.tetris

                        newZoom =
                            case code of
                                189 ->
                                    model.sf * 0.8

                                187 ->
                                    model.sf * 1.25

                                _ ->
                                    model.sf
                    in
                        { model | keysDown = newKeysDown, tetris = newTetris, sf = newZoom }

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
                                        |> gravity 0.5
                                        |> resetGround
                                        |> blockUpdate (ticks model.tetrisSpeed) 0.5 model.tetris
                                        |> keypressedPlayer model.keysDown 0.5 model.jumpSize
                                        |> step 0.5
                                , others =
                                    List.map
                                        (\e ->
                                            e
                                                |> slowedPlayer 0.5
                                                |> gravity 0.5
                                                |> resetGround
                                                |> blockUpdate (ticks model.tetrisSpeed) 0.5 model.tetris
                                                |> step 0.5
                                        )
                                        model.others
                            }

        -- onGround will be set if appropriate in blockUpdate
        -- blockupate has most priority over step params
    in
        let
            newTetris =
                playTetris (ticks newModel.tetrisSpeed) 0.5 newModel.tetris

            newerModel =
                { newModel
                    | sf = ((newModel.sf * 1999) + (newModel.targetSF * 1)) / 2000
                    , tetrisSpeed = ((newModel.tetrisSpeed * 9999) + (newModel.targetTetrisSpeed * 1)) / 10000
                    , tetrisControlsActivated = (abs (model.sf - model.targetSF)) < 0.5
                }
        in
            if (model.player.squish /= 0.0) then
                init
            else
                ( { newerModel | tetris = newTetris }
                , if newTetris.needsRandom then
                    Random.generate NewPiece (Random.int 1 7)
                  else
                    Cmd.none
                )


resetGround e =
    { e | onGround = False }


playTetris : Int -> Float -> TetrisState -> TetrisState
playTetris ticksPerTetrisSquare dt tetris =
    let
        newFraction =
            tetris.fraction + dt * (1 / (toFloat ticksPerTetrisSquare))
    in
        if newFraction > 1 then
            if moveWorks ( 0, -2 ) tetris then
                { tetris | fraction = 0, curSpot = tetris.nextSpot, nextSpot = pointAdd tetris.nextSpot ( 0, -1 ) }
            else
                tetrisDown tetris
        else
            { tetris | fraction = newFraction }


withNewPiece : Int -> TetrisState -> TetrisState
withNewPiece i tetris =
    let
        thing =
            Debug.log "calling withNewPiece"

        withPiece =
            { tetris | needsRandom = False, active = newPiece i }

        ( x, rot ) =
            --Debug.log "Desired xAndRot"
            (desiredXAndRot withPiece)
    in
        { withPiece | curSpot = ( x, 19 ), nextSpot = ( x, 18 ), active = rot }
