module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (div, button, text, br, node)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)
import Array
import StoryView exposing (storyView)
import StoryView exposing (Directional(..))


main =
    beginnerProgram { model = initialWorld, view = view, update = update }


view model =
    div []
        [ css "http://localhost:8080/style.css"
        , js "http://localhost:8080/script.js"
        , button [ onClick Decrement ] [ text "-" ]
        , tetrisView model.tetris
        , storyView model
        , button [ onClick Increment ] [ text "+" ]
        ]


css path =
    node "link" [ rel "stylesheet", href path ] []


js path =
    node "script" [ src path ] []


tetrisView tetris =
    div [ class "board" ] (divGrid tetris)


divGrid grid =
    List.map divRow (rows grid)


divRow row =
    div [ class "board-row" ]
        (List.map
            (\n ->
                div
                    [ class
                        (if n == 1 then
                            "block"
                         else
                            "space"
                        )
                    ]
                    []
            )
            row
        )


rows grid =
    List.map (\i -> Array.toList (Array.slice (i * width) ((i + 1) * width) grid))
        (range height)


range max =
    List.indexedMap (\i x -> i) (List.repeat max 0)


width =
    10


height =
    22


initialBoard =
    Array.initialize (width * height) (\x -> 0)


initialWorld =
    { tetris = exampleBoard, player = { x = 10, y = 10, dir = Left, dx = 0, dy = 0 } }


exampleBoard =
    initialBoard
        |> gridSet 1 2 1
        |> gridSet 1 3 1
        |> gridSet 1 4 1
        |> gridSet 2 4 1



--if out of range, it's a wall


gridGet x y g =
    case Array.get (y * width + x) g of
        Just x ->
            x

        Nothing ->
            1


gridSet x y v grid =
    Array.set (y * width + x) v grid


type Msg
    = Increment
    | Decrement


update msg model =
    model
