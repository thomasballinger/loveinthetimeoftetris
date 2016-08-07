module Main exposing (..)

import Html.Attributes exposing (class, rel, src, href)
import Html exposing (div, button, text, br, node, Html)
import Html.App as App
import Html.Events exposing (onClick)
import Char
import StoryView exposing (storyView, tetrisBlocksWithWalls)
import Entity exposing (..)
import Tetris exposing (divGrid, exampleBoard, TetrisState)
import Keyboard


type alias Model =
    { tetris : TetrisState
    , player : Movable (Standable (Collidable (Drawable {})))
    , sf : Float
    }


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
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.presses KeyMsg


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
    | KeyMsg Keyboard.KeyCode


keypressedPlayer code player =
    case ( Char.fromCode code, player.state ) of
        ( 'w', Standing ) ->
            { player | dy = player.dy + 10, state = Jumping }

        ( 'a', _ ) ->
            { player | dir = Left, dx = max (player.dx - 1) (-10) }

        ( 'd', _ ) ->
            { player | dir = Right, dx = min (player.dx + 1) 10 }

        _ ->
            player


slowedPlayer player =
    { player
        | dx =
            if (abs player.dx) < 0.1 then
                0
            else
                player.dx * 0.6
    }



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

                KeyMsg code ->
                    { model
                        | player =
                            model.player
                                |> slowedPlayer
                                |> keypressedPlayer code
                                |> step 1
                                |> gravity 1
                                |> blockUpdate model.tetris
                    }
    in
        ( newModel, Cmd.none )
