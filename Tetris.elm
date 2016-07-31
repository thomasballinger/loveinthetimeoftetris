module Tetris exposing (divGrid, exampleBoard, onSpots)

import Html.Attributes exposing (class)
import Html exposing (div)
import Array
import Util exposing (range)


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
    List.map (\i -> Array.toList (Array.slice (i * boardWidth) ((i + 1) * boardWidth) grid))
        (range boardHeight)


boardWidth =
    10


boardHeight =
    22


onSpots grid =
    Array.toIndexedList grid
        |> List.filter (\( i, x ) -> x > 0)
        |> List.map (\( i, x ) -> ( i % boardWidth, i // boardWidth ))


initialBoard =
    Array.initialize (boardWidth * boardHeight) (\x -> 0)


gridGet x y g =
    case Array.get (y * boardWidth + x) g of
        Just x ->
            x

        Nothing ->
            1


gridSet x y v grid =
    Array.set (y * boardWidth + x) v grid


exampleBoard =
    initialBoard
        |> gridSet 1 2 1
        |> gridSet 1 3 1
        |> gridSet 1 4 1
        |> gridSet 2 4 1
