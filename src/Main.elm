port module Main exposing (..)

import Html.Attributes exposing (class, rel, src, href, style)
import Html exposing (div, button, text, br, node, Html, a)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import Time
import Progression exposing (Model, bpm, sf, tetrisControlsActivated, tetrisTicks, jumpSize)
import StoryView exposing (storyView)
import Entity exposing (..)
import Others exposing (..)
import Tetris exposing (divGrid, exampleTetrisState, TetrisState, tetrisGrid, tetrisLeft, tetrisRight, tetrisDown, tetrisRotateLeft, tetrisRotateRight, tetrisBlocksWithWalls, moveWorks, pointAdd)
import Piece exposing (newPiece)
import TetrisAI exposing (desiredXAndRot)
import Keyboard
import Random
import Element


port setBPM : Float -> Cmd msg


port touch : (( Bool, Int ) -> msg) -> Sub msg


port resize : (( Int, Int ) -> msg) -> Sub msg


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialWorld, setBPM 20 )


initialWorld =
    { tetris = exampleTetrisState
    , player =
        initialPlayer ( 50, 100 )
        --    , others = [ princess ( 100, 100 ) ]
    , others = []
    , progress = 0
    , lastTick = 0
    , keysDown = { w = False, a = False, s = False, d = False }
    , windowSize = ( 600, 400 )
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDownMsg
        , Keyboard.ups KeyUpMsg
        , Time.every 16 Tick
        , touch Touch
        , resize WinSize
        ]


view : Model -> Html Msg
view model =
    div [ class "game" ] [ Element.toHtml (storyView model.windowSize model) ]


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
    | Touch ( Bool, Int )
    | WinSize ( Int, Int )


keypressedPlayer keysDown dt jump player =
    let
        afterJump =
            if keysDown.w && player.onGround then
                { player | dy = player.dy + jump, onGround = False }
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


setKeysFromCode keysDown value code =
    case Char.fromCode code of
        'W' ->
            { keysDown | w = value }

        'A' ->
            { keysDown | a = value }

        'S' ->
            { keysDown | s = value }

        'D' ->
            { keysDown | d = value }

        _ ->
            keysDown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel =
            case msg of
                WinSize ( w, h ) ->
                    { model | windowSize = ( w, h ) }

                NewPiece i ->
                    { model | tetris = (withNewPiece i model.tetris) }

                Touch ( isStart, code ) ->
                    { model | keysDown = setKeysFromCode model.keysDown isStart code }

                KeyDownMsg code ->
                    let
                        newKeysDown =
                            setKeysFromCode model.keysDown True code

                        newTetris =
                            if tetrisControlsActivated model then
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

                        newProgress =
                            case code of
                                189 ->
                                    max 0 (model.progress - 0.1)

                                187 ->
                                    min 1 (model.progress + 0.1)

                                _ ->
                                    model.progress
                    in
                        { model | keysDown = newKeysDown, tetris = newTetris, progress = newProgress }

                KeyUpMsg code ->
                    let
                        keysDown =
                            model.keysDown

                        newKeysDown =
                            setKeysFromCode keysDown False code
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
                                        |> blockUpdate (tetrisTicks model) 0.5 model.tetris
                                        |> keypressedPlayer model.keysDown 0.5 (jumpSize model)
                                        |> step 0.5
                                , others =
                                    List.map
                                        (\e ->
                                            e
                                                |> slowedPlayer 0.5
                                                |> gravity 0.5
                                                |> resetGround
                                                |> blockUpdate (tetrisTicks model) 0.5 model.tetris
                                                |> step 0.5
                                        )
                                        model.others
                            }

        -- onGround will be set if appropriate in blockUpdate
        -- blockupate has most priority over step params
    in
        let
            newTetris =
                playTetris (tetrisTicks model) 0.5 newModel.tetris

            newerModel =
                { newModel
                    | progress =
                        let
                            desired =
                                (newModel.progress + 0.0002)
                        in
                            if (desired > 0.99999999) then
                                0.99999998
                                -- Hack to prevent from gif
                                -- from getting stuck in first frame
                                -- this is probably a bug with whatever
                                -- in Elm Graphics loads gifs
                            else
                                desired
                }
        in
            if (model.player.squish /= 0.0) then
                ( { initialWorld | windowSize = model.windowSize }, setBPM 20 )
            else
                ( { newerModel | tetris = newTetris }
                , Cmd.batch
                    [ setBPM (bpm newModel)
                    , if newTetris.needsRandom then
                        Random.generate NewPiece (Random.int 1 7)
                      else
                        Cmd.none
                    ]
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
        withPiece =
            { tetris | needsRandom = False, active = newPiece i }

        ( x, rot ) =
            --Debug.log "Desired xAndRot"
            (desiredXAndRot withPiece)
    in
        { withPiece | curSpot = ( x, 19 ), nextSpot = ( x, 18 ), active = rot }
