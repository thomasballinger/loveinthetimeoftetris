module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import Tetris
import Piece
import TetrisAI


all : Test
all =
    describe "Elm Tetris"
        [ describe "Tetris"
            [ test "finding piece resting position"
                <| \() ->
                    Expect.equal (Tetris.smallestY Tetris.exampleTetrisState) (Just -1)
            , describe "piece rotations"
                (List.map pieceHasRotations
                    [ ( Piece.pieceI1, 2 )
                    , ( Piece.pieceO, 1 )
                    , ( Piece.pieceJ1, 4 )
                    , ( Piece.pieceL1, 4 )
                    , ( Piece.pieceS1, 2 )
                    , ( Piece.pieceT1, 4 )
                    , ( Piece.pieceZ1, 2 )
                    ]
                )
            , test "piece rotate"
                <| \() ->
                    Expect.equal (Piece.rotate Piece.pieceI1) Piece.pieceI2
            ]
        , describe "TetrisAI heuristics"
            [ test "numFilled"
                <| \() -> Expect.equal 4 (TetrisAI.numFilled (Tetris.tetrisGrid (Tetris.TetrisState Tetris.initialBoard Piece.pieceJ1 ( 4, -1 ) ( 1000, 1000 ) 0 False)))
            , test "linearPenalty"
                <| \() -> Expect.equal 5 (TetrisAI.linearPenalty (Tetris.tetrisGrid (Tetris.TetrisState Tetris.initialBoard Piece.pieceJ1 ( 4, -1 ) ( 1000, 1000 ) 0 False)))
            , test "numCovered"
                <| \() -> Expect.equal 0 (TetrisAI.numCovered (Tetris.tetrisGrid (Tetris.TetrisState Tetris.initialBoard Piece.pieceJ1 ( 4, -1 ) ( 1000, 1000 ) 0 False)))
            , test "numSidesFilled"
                <| \() -> Expect.equal 0 (TetrisAI.numSidesFilled (Tetris.tetrisGrid (Tetris.TetrisState Tetris.initialBoard Piece.pieceJ1 ( 4, -1 ) ( 1000, 1000 ) 0 False)))
            ]
        , describe "TetrisAI state space"
            [ test "boardStates"
                <| \() ->
                    Expect.equal (Tetris.boardCols - 1)
                        (List.length (TetrisAI.boardStates (Tetris.TetrisState Tetris.initialBoard Piece.pieceO ( 0, Tetris.boardRows - 4 ) ( 1000, 1000 ) 0 False)))
            , test "boardStates"
                <| \() ->
                    Expect.equal (Tetris.boardCols - 3 + Tetris.boardCols)
                        (List.length (TetrisAI.boardStates (Tetris.TetrisState Tetris.initialBoard Piece.pieceI1 ( 0, Tetris.boardRows - 4 ) ( 1000, 1000 ) 0 False)))
            , test "bestOSpot"
                <| \() ->
                    -- if the sort of states isn't stable, this could be a different value
                    Expect.equal ( 0, Piece.pieceO )
                        (TetrisAI.desiredXAndRot (Tetris.TetrisState Tetris.initialBoard Piece.pieceO ( 0, Tetris.boardRows - 4 ) ( 1000, 1000 ) 0 False))
            , test "bestJSpot"
                <| \() ->
                    -- if the sort of states isn't stable, this could be a different value
                    let
                        tetris =
                            Tetris.TetrisState Tetris.initialBoard Piece.pieceJ1 ( 0, Tetris.boardRows - 4 ) ( 1000, 1000 ) 0 False
                    in
                        Expect.equal ( 0, Piece.pieceJ1 )
                            (TetrisAI.desiredXAndRot tetris)
            ]
        ]


pieceHasRotations : ( Piece.Piece, Int ) -> Test
pieceHasRotations ( piece, n ) =
    test
        ("piece "
            ++ toString piece
            ++ "has right number of rotations"
        )
        <| \() ->
            Expect.equal (List.length (Piece.rotations piece)) n
