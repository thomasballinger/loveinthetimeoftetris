module Tetris exposing (divGrid, exampleBoard, onSpots, boardRows, boardCols, TetrisState)

import Html.Attributes exposing (class)
import Html exposing (div)
import Array
import Util exposing (range)
import Entity exposing (Collidable)


type alias TetrisState =
    Array.Array Int


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
    List.map (\i -> Array.toList (Array.slice (i * boardCols) ((i + 1) * boardCols) grid))
        (range boardRows)


boardCols =
    10


boardRows =
    22


onSpots grid =
    Array.toIndexedList grid
        |> List.filter (\( i, x ) -> x > 0)
        |> List.map (\( i, x ) -> ( i % boardCols, i // boardCols ))


initialBoard =
    Array.initialize (boardCols * boardRows) (\x -> 0)


gridGet x y g =
    case Array.get (y * boardCols + x) g of
        Just x ->
            x

        Nothing ->
            1


gridSet x y v grid =
    Array.set (y * boardCols + x) v grid


exampleBoard : Array.Array Int
exampleBoard =
    initialBoard
        |> gridSet 1 2 1
        |> gridSet 1 3 1
        |> gridSet 1 4 1
        |> gridSet 2 4 1
