module TetrisAI exposing (desiredXAndRot, evaluate, numFilled, numCovered, linearPenalty, numSidesFilled, boardStates)

import Tetris exposing (..)
import Piece exposing (..)
import List
import Array


desiredXAndRot : TetrisState -> ( Int, Piece.Piece )
desiredXAndRot tetris =
    let
        candidates =
            --Debug.log "candidates"
            (List.map (\t -> ( t, evaluate t )) (boardStates tetris))
    in
        case List.head (List.reverse (List.sortBy (\( t, score ) -> score) candidates)) of
            Just ( t, score ) ->
                let
                    -- thing = Debug.log "Score and board:" ( score, t )
                    ( x, _ ) =
                        t.curSpot
                in
                    ( x, t.active )

            Nothing ->
                ( 4, tetris.active )


evaluate : TetrisState -> Float
evaluate tetris =
    let
        grid =
            tetrisGrid tetris
    in
        List.sum
            [ --Debug.log "num filled"
              ((-1.0) * toFloat (numFilled grid))
            , --Debug.log "linear penalty"
              (-0.2 * toFloat (linearPenalty grid))
            , --Debug.log "num covered"
              (-10.0 * toFloat (numCovered grid))
            , --Debug.log "sides filled"
              (1.0 * toFloat (numSidesFilled grid))
            ]



-- Producing all possible boards, given an active piece


boardStates : TetrisState -> List TetrisState
boardStates tetris =
    let
        rots =
            --Debug.log "rotations"
            (rotations tetris.active)

        xs =
            List.indexedMap (\i x -> i) (List.repeat boardCols 0)

        xRotPairs =
            --Debug.log "xRotPairs"
            (List.concatMap (\rot -> List.map (\y -> ( y, rot )) xs) rots)
    in
        List.filter
            (\t ->
                let
                    ( _, smally ) =
                        --Debug.log "spot"
                        t.curSpot
                in
                    smally > -10
            )
            (List.map
                (\( x, rot ) ->
                    let
                        t =
                            { tetris | curSpot = ( x, boardRows - 1 ), active = rot }

                        y =
                            case smallestY t of
                                Just smallY ->
                                    smallY

                                Nothing ->
                                    -10
                    in
                        { tetris | curSpot = ( x, y ), active = rot }
                )
                xRotPairs
            )



--e1 = Evaluator((total_blocks, -1), (linear_height_penalty, -.2), (empties_with_block_right_above, -10), (covered_sides, 1))
-- Evaluator functions


numFilled : Array.Array Int -> Int
numFilled grid =
    List.length (onSpots grid)


linearPenalty : Array.Array Int -> Int
linearPenalty grid =
    List.sum (List.map (\( x, y ) -> y + 1) (onSpots grid))


numCovered : Array.Array Int -> Int
numCovered grid =
    List.length (List.filter (\( x, y ) -> (gridGet x (y - 1) grid) == 0) (onSpots grid))


numSidesFilled : Array.Array Int -> Int
numSidesFilled grid =
    List.length (List.filter (\( x, y ) -> (x == 0) || (x == boardCols)) (onSpots grid))



-- * total number of filled spaces
-- * linear lheight penalty: 1 per block on first row, 2 per block on second row, etc.
-- * number of empties with block right above
-- * number of sides of the board covered
-- To start with, use -1 * total blocks + -.2 times linear height + -10 * empties
