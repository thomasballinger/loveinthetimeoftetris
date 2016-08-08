module Tetris exposing (divGrid, onSpots, boardRows, boardCols, TetrisState, tetrisGrid, exampleTetrisState, tetrisRight, tetrisLeft, tetrisDown)

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


pieceGrid : Piece -> ( Int, Int ) -> Array.Array Int
pieceGrid p ( dx, dy ) =
    spotsOnGrid p.texture (movedSpots ( dx, dy ) p.spots)


spotsOnGrid : Int -> List ( Int, Int ) -> Array.Array Int
spotsOnGrid v spots =
    List.foldl (\spot acc -> gridSet spot v acc) initialBoard spots


pieceSpots : Piece -> ( Int, Int ) -> List ( Int, Int )
pieceSpots p ( dx, dy ) =
    List.map (pointAdd ( dx, dy )) p.spots


tetrisGrid : TetrisState -> Array.Array Int
tetrisGrid tetris =
    arrayAdd tetris.dead (pieceGrid tetris.active tetris.curSpot)


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
                        (if n > 0 then
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


isLegal : ( Int, Int ) -> Bool
isLegal ( x, y ) =
    (x >= 0 && y >= 0 && x < boardCols && y < boardRows)


gridSet : ( Int, Int ) -> a -> Array.Array a -> Array.Array a
gridSet ( x, y ) v grid =
    Array.set (y * boardCols + x) v grid


movedSpots : ( Int, Int ) -> List ( Int, Int ) -> List ( Int, Int )
movedSpots ( dx, dy ) =
    List.map (\( x, y ) -> ( x + dx, y + dy ))


spotsLeft =
    movedSpots ( -1, 0 )


pointAdd ( x1, y1 ) ( x2, y2 ) =
    ( (x1 + x2), (y1 + y2) )


allPosToOne : Int -> Int
allPosToOne n =
    if n > 0 then
        1
    else
        0


arrayAll : (a -> Bool) -> Array.Array a -> Bool
arrayAll predicate arr =
    List.all predicate (Array.toList arr)


spotsClear : Array.Array Int -> List ( Int, Int ) -> Bool
spotsClear grid spots =
    arrayAll ((>) 2) (arrayAdd (Array.map allPosToOne grid) (spotsOnGrid 1 spots))



-- playing tetris


pieceMove : ( Int, Int ) -> TetrisState -> TetrisState
pieceMove ( dx, dy ) tetris =
    let
        newSpots =
            movedSpots ( dx, dy ) (pieceSpots tetris.active tetris.curSpot)
    in
        if ((List.all isLegal newSpots) && (spotsClear tetris.dead newSpots)) then
            { tetris | curSpot = pointAdd tetris.curSpot ( dx, dy ) }
        else if dy /= 0 then
            let
                newGrid =
                    tetrisGrid tetris
            in
                { tetris | dead = newGrid, active = newPiece 1, curSpot = ( 4, 10 ) }
        else
            tetris


tetrisDown =
    pieceMove ( 0, -1 )


tetrisLeft =
    pieceMove ( -1, 0 )


tetrisRight =
    pieceMove ( 1, 0 )
