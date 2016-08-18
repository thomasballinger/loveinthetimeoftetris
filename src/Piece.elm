module Piece exposing (..)

import List


type Piece
    = PieceI1
    | PieceI2
    | PieceO
    | PieceL1
    | PieceL2
    | PieceL3
    | PieceL4
    | PieceJ1
    | PieceJ2
    | PieceJ3
    | PieceJ4
    | PieceS1
    | PieceS2
    | PieceT1
    | PieceT2
    | PieceT3
    | PieceT4
    | PieceZ1
    | PieceZ2



-- matches GameBoy rotation system


spots : Piece -> List ( Int, Int )
spots piece =
    case piece of
        PieceI1 ->
            [ ( 0, 2 ), ( 1, 2 ), ( 2, 2 ), ( 3, 2 ) ]

        PieceI2 ->
            [ ( 2, 0 ), ( 2, 1 ), ( 2, 2 ), ( 2, 3 ) ]

        PieceO ->
            [ ( 0, 1 ), ( 0, 2 ), ( 1, 1 ), ( 1, 2 ) ]

        PieceL1 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ]

        PieceL2 ->
            [ ( 0, 2 ), ( 1, 2 ), ( 1, 1 ), ( 1, 0 ) ]

        PieceL3 ->
            [ ( 0, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ]

        PieceL4 ->
            [ ( 1, 2 ), ( 1, 1 ), ( 1, 0 ), ( 2, 0 ) ]

        PieceJ1 ->
            [ ( 0, 2 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ]

        PieceJ2 ->
            [ ( 0, 0 ), ( 1, 0 ), ( 1, 1 ), ( 1, 2 ) ]

        PieceJ3 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 0 ) ]

        PieceJ4 ->
            [ ( 1, 0 ), ( 1, 1 ), ( 1, 2 ), ( 2, 2 ) ]

        PieceS1 ->
            [ ( 0, 2 ), ( 1, 2 ), ( 1, 1 ), ( 2, 1 ) ]

        PieceS2 ->
            [ ( 1, 0 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ]

        PieceT1 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 1, 2 ) ]

        PieceT2 ->
            [ ( 1, 0 ), ( 1, 1 ), ( 2, 1 ), ( 1, 2 ) ]

        PieceT3 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 1, 0 ) ]

        PieceT4 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 1, 0 ), ( 1, 2 ) ]

        PieceZ1 ->
            [ ( 0, 1 ), ( 1, 1 ), ( 1, 2 ), ( 2, 2 ) ]

        PieceZ2 ->
            [ ( 1, 2 ), ( 1, 1 ), ( 2, 1 ), ( 2, 0 ) ]


rotate : Piece -> Piece
rotate p =
    case p of
        PieceI1 ->
            PieceI2

        PieceI2 ->
            PieceI1

        PieceO ->
            PieceO

        PieceJ1 ->
            PieceJ2

        PieceJ2 ->
            PieceJ3

        PieceJ3 ->
            PieceJ4

        PieceJ4 ->
            PieceJ1

        PieceL1 ->
            PieceL2

        PieceL2 ->
            PieceL3

        PieceL3 ->
            PieceL4

        PieceL4 ->
            PieceL1

        PieceS1 ->
            PieceS2

        PieceS2 ->
            PieceS1

        PieceT1 ->
            PieceT2

        PieceT2 ->
            PieceT3

        PieceT3 ->
            PieceT4

        PieceT4 ->
            PieceT1

        PieceZ1 ->
            PieceZ2

        PieceZ2 ->
            PieceZ1


newPiece : Int -> Piece
newPiece rn =
    case rn % 7 of
        0 ->
            PieceI1

        1 ->
            PieceO

        2 ->
            PieceJ1

        3 ->
            PieceL1

        4 ->
            PieceS1

        5 ->
            PieceT1

        6 ->
            PieceZ1

        _ ->
            Debug.crash "no dependent types in Elm"


rotations : Piece -> List Piece
rotations piece =
    case piece of
        PieceO ->
            [ PieceO ]

        _ ->
            rotations' [ piece ]


rotations' : List Piece -> List Piece
rotations' states =
    case states of
        first :: rest ->
            let
                last =
                    case
                        List.head (List.reverse rest)
                    of
                        Just state ->
                            state

                        Nothing ->
                            first

                next =
                    rotate first
            in
                if (next == last) && (List.length states > 1) then
                    states
                else
                    rotations' (next :: states)

        [] ->
            states
