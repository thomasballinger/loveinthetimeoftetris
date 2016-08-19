module Tetris exposing (divGrid, boardRows, boardCols, TetrisState, grid, exampleState, tetrisRight, tetrisLeft, tetrisDown, displayBlocks, displayWalls, walls, tetrisBlocksWithWalls, moveWorks, pointAdd, onSpots, gridGet, smallestY, initialBoard, clearLines, tetrisRotateLeft, tetrisRotateRight)

import Html.Attributes exposing (class)
import Html exposing (div)
import Array
import Set
import Color exposing (Color, rgb)
import Entity exposing (Drawable, EntityState(..), Directional(..), drawInfoColor)
import Piece exposing (..)


type alias TetrisState =
    { dead : Array.Array Int
    , active : Piece
    , curSpot : ( Int, Int )
    , nextSpot : ( Int, Int )
    , fraction : Float
    , needsRandom : Bool
    }


exampleState : TetrisState
exampleState =
    (TetrisState initialBoard PieceJ1 ( 4, 2 ) ( 4, 1 ) 0 False)


pieceGrid : Piece -> ( Int, Int ) -> Array.Array Int
pieceGrid p ( dx, dy ) =
    spotsOnGrid 1 (movedSpots ( dx, dy ) (spots p))


spotsOnGrid : Int -> List ( Int, Int ) -> Array.Array Int
spotsOnGrid v spots =
    List.foldl (\spot acc -> gridSet spot v acc) initialBoard spots


pieceSpots : Piece -> ( Int, Int ) -> List ( Int, Int )
pieceSpots p ( dx, dy ) =
    List.map (pointAdd ( dx, dy )) (spots p)


grid : TetrisState -> Array.Array Int
grid tetris =
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


divGrid : Array.Array Int -> List (Html.Html msg)
divGrid grid =
    List.map divRow (List.reverse (rows grid))


divRow : List Int -> Html.Html msg
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
        [0..(boardRows - 1)]


boardCols : Int
boardCols =
    10


boardRows : Int
boardRows =
    22


onSpots : Array.Array Int -> List ( Int, Int )
onSpots grid =
    Array.toIndexedList grid
        |> List.filter (\( i, x ) -> x > 0)
        |> List.map (\( i, x ) -> ( i % boardCols, i // boardCols ))


initialBoard : Array.Array Int
initialBoard =
    Array.initialize (boardCols * boardRows) (\x -> 0)


gridGet : Int -> Int -> Array.Array Int -> Int
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


spotsLeft : List ( Int, Int ) -> List ( Int, Int )
spotsLeft =
    movedSpots ( -1, 0 )


pointAdd : ( Int, Int ) -> ( Int, Int ) -> ( Int, Int )
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


clearLines : Array.Array Int -> Array.Array Int
clearLines grid =
    let
        rowsLeft =
            List.filter (List.any (\value -> value == 0)) (rows grid)

        numCleared =
            boardRows - (List.length rowsLeft)
    in
        Array.fromList
            ((List.concat rowsLeft)
                ++ (List.repeat (boardCols * (boardRows - (List.length rowsLeft))) 0)
            )



-- freeze piece, remove lines, new piece


nextPiece : TetrisState -> TetrisState
nextPiece tetris =
    let
        newGrid =
            clearLines (grid tetris)
    in
        { tetris | dead = newGrid, active = newPiece 1, curSpot = ( 4, 20 ), nextSpot = ( 4, 19 ), fraction = 0, needsRandom = True }



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
        nextPiece tetris
    else
        tetris


pieceRotate : Int -> TetrisState -> TetrisState
pieceRotate n tetris =
    let
        rot =
            rotate tetris.active
    in
        if moveWorks ( 0, 0 ) { tetris | active = rot } then
            { tetris | active = rot }
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


tetrisDown : TetrisState -> TetrisState
tetrisDown =
    pieceMove ( 0, -1 )


tetrisLeft : TetrisState -> TetrisState
tetrisLeft =
    pieceMove ( -1, 0 )


tetrisRight : TetrisState -> TetrisState
tetrisRight =
    pieceMove ( 1, 0 )


tetrisRotateLeft : TetrisState -> TetrisState
tetrisRotateLeft =
    pieceRotate 1


tetrisRotateRight : TetrisState -> TetrisState
tetrisRotateRight =
    pieceRotate 3


piecePix =
    100



-- tetris blocks: transform to play space


walls : List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
walls =
    [ { x = (toFloat boardCols / 2) * piecePix - (piecePix / 2)
      , y = toFloat -3 * (piecePix / 2)
      , w = toFloat (piecePix * (boardCols + 1))
      , h = toFloat piecePix
      , dx = 0.0
      , dy = 0.0
      }
    , { x = (toFloat boardCols / 2) * piecePix - (piecePix / 2)
      , y = toFloat (boardRows * piecePix) + (piecePix / 2)
      , w = toFloat (piecePix * (boardCols + 1))
      , h = toFloat piecePix
      , dx = 0.0
      , dy = 0.0
      }
    , { x = toFloat -3 * (piecePix / 2)
      , y = toFloat piecePix * (toFloat boardRows / 2) - (piecePix / 2)
      , w = toFloat piecePix
      , h = toFloat ((boardRows + 3) * piecePix)
      , dx = 0.0
      , dy = 0.0
      }
    , { x = toFloat (piecePix * boardCols) - (piecePix / 2)
      , y = toFloat piecePix * (toFloat boardRows / 2) - (piecePix / 2)
      , w = toFloat piecePix
      , h = toFloat ((boardRows + 3) * piecePix)
      , dx = 0.0
      , dy = 0.0
      }
    ]


displayBlocks : TetrisState -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool, squish : Float }
displayBlocks tetris =
    (List.map (xywhToDrawable (rgb 200 200 200)) (shadowRects tetris))
        ++ (tetrisBlocks (-10000) 0 tetris
                |> List.map (xywhToDrawable (rgb 0 200 0))
           )


shadowRects : TetrisState -> List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
shadowRects tetris =
    let
        fallingBlocks =
            List.map (floatToWorldCords (-1000)) (interpolatedActive tetris)

        xs =
            Set.toList (Set.fromList (List.map .x fallingBlocks))

        yFromX =
            (\x ->
                case List.minimum (List.map .y (List.filter (\block -> block.x == x) fallingBlocks)) of
                    Just n ->
                        n

                    Nothing ->
                        Debug.crash "block with no y coordinate?"
            )
    in
        List.map
            (\x ->
                let
                    y =
                        yFromX x
                in
                    { x = x, y = (y - (piecePix * 2)) / 2, w = piecePix * 1.02, h = y + piecePix, dx = 0.0, dy = 0.0 }
            )
            xs


displayWalls : List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float } -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool, squish : Float }
displayWalls walls =
    List.map (xywhToDrawable (rgb 100 0 0)) walls


xywhToDrawable : Color -> { a | x : Float, y : Float, w : Float, h : Float } -> { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState, onGround : Bool, squish : Float }
xywhToDrawable color { x, y, w, h } =
    { x = x
    , y = y
    , drawinfo = drawInfoColor color w h
    , dir = Neither
    , state = Standing
    , onGround = True
    , squish = 0.0
    }


toWorldCords : ( Int, Int ) -> { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
toWorldCords ( x, y ) =
    { x = toFloat x * piecePix - (piecePix / 2), y = toFloat y * piecePix - (piecePix / 2), w = piecePix, h = piecePix, dx = 0.0, dy = 0.0 }


floatToWorldCords : Int -> ( Float, Float ) -> { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
floatToWorldCords ticksPerTetrisSquare ( x, y ) =
    { x = x * piecePix - (piecePix / 2), y = y * piecePix - (piecePix / 2), w = toFloat piecePix, h = toFloat piecePix, dx = 0.0, dy = -piecePix * (1 / (toFloat ticksPerTetrisSquare)) }


w0v : { a | dx : Float, dy : Float } -> { a | dx : Float, dy : Float }
w0v e =
    { e | dx = 0, dy = 0 }


tetrisBlocks : Int -> Float -> TetrisState -> List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
tetrisBlocks ticksPerTetrisSquare dt tetris =
    (List.map toWorldCords (onSpots tetris.dead))
        ++ (List.map (floatToWorldCords ticksPerTetrisSquare) (interpolatedActive tetris))


interpolatedActive : TetrisState -> List ( Float, Float )
interpolatedActive tetris =
    let
        ( dx, dy ) =
            pointPropAdd tetris.fraction tetris.curSpot tetris.nextSpot
    in
        List.map (\( x, y ) -> ( (toFloat x) + dx, (toFloat y) + dy )) (spots tetris.active)


tetrisBlocksWithWalls : Int -> Float -> TetrisState -> List { x : Float, y : Float, w : Float, h : Float, dx : Float, dy : Float }
tetrisBlocksWithWalls ticksPerTetrisSquare dt tetris =
    (tetrisBlocks ticksPerTetrisSquare dt tetris) ++ walls
