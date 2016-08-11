module Tetris exposing (divGrid, boardRows, boardCols, TetrisState, tetrisGrid, exampleTetrisState, tetrisRight, tetrisLeft, tetrisDown, displayBlocks, displayWalls, walls, tetrisBlocksWithWalls, moveWorks, pointAdd, ticksPerTetrisSquare, onSpots, gridGet, smallestY, initialBoard)

import Html.Attributes exposing (class)
import Html exposing (div)
import Array
import Util exposing (range)
import Color exposing (Color, rgb)
import Entity exposing (Collidable, Drawable, EntityState(..), Directional(..), drawInfoColor)
import Piece exposing (..)


type alias TetrisState =
    { dead : Array.Array Int
    , active : Piece
    , curSpot : ( Int, Int )
    , nextSpot : ( Int, Int )
    , fraction : Float
    , needsRandom : Bool
    }


exampleTetrisState : TetrisState
exampleTetrisState =
    (TetrisState initialBoard pieceJ1 ( 4, 2 ) ( 4, 1 ) 0 False)


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
    List.map divRow (List.reverse (rows grid))


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


rows : Array.Array Int -> List (List Int)
rows grid =
    List.map (\i -> Array.toList (Array.slice (i * boardCols) ((i + 1) * boardCols) grid))
        (range boardRows)


boardCols =
    10


boardRows =
    22


onSpots : Array.Array Int -> List ( Int, Int )
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
    (x >= 0 && y >= 0 && x < boardCols)


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


pointPropAdd : Float -> ( Int, Int ) -> ( Int, Int ) -> ( Float, Float )
pointPropAdd portion ( x1, y1 ) ( x2, y2 ) =
    ( ((toFloat x1) * (1.0 - portion) + ((toFloat x2) * portion))
    , ((toFloat y1) * (1.0 - portion) + ((toFloat y2) * portion))
    )


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
    if moveWorks ( dx, dy ) tetris then
        let
            newSpot =
                pointAdd tetris.curSpot ( dx, dy )
        in
            { tetris | curSpot = newSpot, nextSpot = newSpot, fraction = 0 }
    else if dy /= 0 then
        let
            newGrid =
                tetrisGrid tetris
        in
            { tetris | dead = newGrid, active = newPiece 1, curSpot = ( 4, 20 ), nextSpot = ( 4, 19 ), fraction = 0, needsRandom = True }
    else
        tetris


smallestY : TetrisState -> Maybe Int
smallestY tetris =
    if moveWorks ( 0, 0 ) tetris then
        Just (smallestY' tetris 0)
    else
        Nothing


smallestY' : TetrisState -> Int -> Int
smallestY' tetris dy =
    if moveWorks ( 0, dy - 1 ) tetris then
        smallestY' tetris (dy - 1)
    else
        let
            ( x, y ) =
                tetris.curSpot
        in
            y + dy


moveWorks : ( Int, Int ) -> TetrisState -> Bool
moveWorks ( dx, dy ) tetris =
    let
        newSpots =
            movedSpots ( dx, dy ) (pieceSpots tetris.active tetris.curSpot)
    in
        (List.all isLegal newSpots) && (spotsClear tetris.dead newSpots)


tetrisDown =
    pieceMove ( 0, -1 )


tetrisLeft =
    pieceMove ( -1, 0 )


tetrisRight =
    pieceMove ( 1, 0 )


piecePix =
    100


ticksPerTetrisSquare =
    10



-- tetris blocks: transform to play space


walls =
    [ { x = (boardCols / 2) * piecePix - (piecePix / 2)
      , y = toFloat -3 * (piecePix / 2)
      , w = toFloat (piecePix * (boardCols + 1))
      , h = toFloat piecePix
      , dx = 0
      , dy = 0
      }
    , { x = (boardCols / 2) * piecePix - (piecePix / 2)
      , y = toFloat (boardRows * piecePix) + (piecePix / 2)
      , w = toFloat (piecePix * (boardCols + 1))
      , h = toFloat piecePix
      , dx = 0
      , dy = 0
      }
    , { x = toFloat -3 * (piecePix / 2)
      , y = toFloat piecePix * (boardRows / 2) - (piecePix / 2)
      , w = toFloat piecePix
      , h = toFloat ((boardRows + 3) * piecePix)
      , dx = 0
      , dy = 0
      }
    , { x = toFloat (piecePix * boardCols) - (piecePix / 2)
      , y = toFloat piecePix * (boardRows / 2) - (piecePix / 2)
      , w = toFloat piecePix
      , h = toFloat ((boardRows + 3) * piecePix)
      , dx = 0
      , dy = 0
      }
    ]


displayBlocks : TetrisState -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool }
displayBlocks tetris =
    tetrisBlocks 0 tetris
        |> List.map (xywhToDrawable (rgb 0 200 0))


displayWalls : List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float } -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool }
displayWalls walls =
    List.map (xywhToDrawable (rgb 100 0 0)) walls


xywhToDrawable : Color -> { a | x : Float, y : Float, w : Float, h : Float } -> { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool }
xywhToDrawable color { x, y, w, h } =
    { x = x
    , y = y
    , drawinfo = drawInfoColor color w h
    , dir = Neither
    , state = Standing
    , onGround = True
    }


toWorldCords : ( Int, Int ) -> { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
toWorldCords ( x, y ) =
    { x = toFloat x * piecePix - (piecePix / 2), y = toFloat y * piecePix - (piecePix / 2), w = piecePix, h = piecePix, dx = 0.0, dy = 0.0 }


floatToWorldCords : ( Float, Float ) -> { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
floatToWorldCords ( x, y ) =
    { x = x * piecePix - (piecePix / 2), y = y * piecePix - (piecePix / 2), w = toFloat piecePix, h = toFloat piecePix, dx = 0.0, dy = -piecePix * (1 / ticksPerTetrisSquare) }


w0v e =
    { e | dx = 0, dy = 0 }


tetrisBlocks : Float -> TetrisState -> List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
tetrisBlocks dt tetris =
    (List.map toWorldCords (onSpots tetris.dead))
        ++ (List.map floatToWorldCords (interpolatedActive tetris))


interpolatedActive tetris =
    let
        ( dx, dy ) =
            pointPropAdd tetris.fraction tetris.curSpot tetris.nextSpot
    in
        List.map (\( x, y ) -> ( (toFloat x) + dx, (toFloat y) + dy )) tetris.active.spots


tetrisBlocksWithWalls dt tetris =
    (tetrisBlocks dt tetris) ++ walls
