module Tetris exposing (divGrid, onSpots, boardRows, boardCols, TetrisState, spots, exampleTetrisState)

import Html.Attributes exposing (class)
import Html exposing (div)
import Array
import Util exposing (range)
import Entity exposing (Collidable)
import Piece exposing (..)


type alias TetrisState =
    { dead : Array.Array Int
    , active : Piece
    , curSpot : ( Int, Int )
    , nextSpot : ( Int, Int )
    , fraction : Float
    }


exampleTetrisState : TetrisState
exampleTetrisState =
    (TetrisState initialBoard pieceJ1 ( 4, 2 ) ( 4, 1 ) 0)


pieceSpots : Piece -> ( Int, Int ) -> Array.Array Int
pieceSpots p ( dx, dy ) =
    List.foldl (\( x, y ) -> gridSet (x + dx) (y + dy) p.texture) initialBoard p.spots


spots : TetrisState -> Array.Array Int
spots tetris =
    arrayAdd tetris.dead (pieceSpots tetris.active tetris.curSpot)


arrayAdd : Array.Array Int -> Array.Array Int -> Array.Array Int
arrayAdd a1 a2 =
    Array.indexedMap
        (\i v ->
            let
                other =
                    case Array.get i a2 of
                        Nothing ->
                            0

                        Just num ->
                            num
            in
                v + other
        )
        a1


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
