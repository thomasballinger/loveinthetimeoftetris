module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (div, button, text, br, node)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)
import Array
import Collage exposing (collage, toForm)
import Element exposing (show)
import Text


main =
    beginnerProgram { model = exampleBoard, view = view, update = update }


view model =
    div []
        [ css "http://localhost:8080/style.css"
        , js "http://localhost:8080/script.js"
        , button [ onClick Decrement ] [ text "-" ]
        , tetrisView model
        , storyView { a = 1 }
        , button [ onClick Increment ] [ text "+" ]
        ]


css path =
    node "link" [ rel "stylesheet", href path ] []


js path =
    node "script" [ src path ] []


storyView world =
    Element.toHtml (collage 200 200 [ Collage.text (Text.fromString (toString world)) ])


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
    case msg of
        Increment ->
            gridSet 2 3 ((gridGet 2 3 model) + 1) model

        Decrement ->
            gridSet 2 3 -10 model
