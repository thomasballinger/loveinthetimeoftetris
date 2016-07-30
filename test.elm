module Main exposing (..)

import Html.Attributes exposing (..)
import Html exposing (div, button, text, br)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)
import Array


main =
    beginnerProgram { model = initialBoard, view = view, update = update }


view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [ class "board" ] (divGrid model)
        , button [ onClick Increment ] [ text "+" ]
        ]


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
