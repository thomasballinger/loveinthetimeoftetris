module Piece exposing (..)


type alias Piece =
    { spots : List ( Int, Int )
    , texture : Int
    }



-- matches GameBoy rotation system


pieceI1 =
    Piece [ ( 0, 2 ), ( 1, 2 ), ( 2, 2 ), ( 3, 2 ) ] 1


pieceI2 =
    Piece [ ( 2, 0 ), ( 2, 1 ), ( 2, 2 ), ( 2, 3 ) ] 1


pieceO =
    Piece [ ( 0, 0 ), ( 0, 1 ), ( 1, 0 ), ( 1, 1 ) ] 2


pieceJ1 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ] 3


pieceJ2 =
    Piece [ ( 0, 2 ), ( 1, 2 ), ( 1, 1 ), ( 1, 0 ) ] 3


pieceJ3 =
    Piece [ ( 0, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ] 3


pieceJ4 =
    Piece [ ( 1, 2 ), ( 1, 1 ), ( 1, 0 ), ( 2, 0 ) ] 3


pieceL1 =
    Piece [ ( 0, 2 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ] 4


pieceL2 =
    Piece [ ( 0, 0 ), ( 1, 0 ), ( 1, 1 ), ( 1, 2 ) ] 4


pieceL3 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 2, 0 ) ] 4


pieceL4 =
    Piece [ ( 1, 0 ), ( 1, 1 ), ( 1, 2 ), ( 2, 2 ) ] 4


pieceS1 =
    Piece [ ( 0, 2 ), ( 1, 2 ), ( 1, 1 ), ( 2, 1 ) ] 5


pieceS2 =
    Piece [ ( 1, 0 ), ( 1, 1 ), ( 2, 1 ), ( 2, 2 ) ] 5


pieceT1 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 1, 2 ) ] 6


pieceT2 =
    Piece [ ( 1, 0 ), ( 1, 1 ), ( 2, 1 ), ( 1, 2 ) ] 6


pieceT3 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ), ( 1, 0 ) ] 6


pieceT4 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 1, 0 ), ( 1, 2 ) ] 6


pieceZ1 =
    Piece [ ( 0, 1 ), ( 1, 1 ), ( 1, 2 ), ( 2, 2 ) ] 7


pieceZ2 =
    Piece [ ( 1, 2 ), ( 1, 1 ), ( 2, 1 ), ( 2, 0 ) ] 7


rotate : Piece -> Piece
rotate p =
    if p == pieceI1 then
        pieceI2
    else if p == pieceI2 then
        pieceI1
    else if p == pieceO then
        pieceO
    else if p == pieceJ1 then
        pieceJ2
    else if p == pieceJ2 then
        pieceJ3
    else if p == pieceJ3 then
        pieceJ4
    else if p == pieceJ4 then
        pieceJ1
    else if p == pieceL1 then
        pieceL2
    else if p == pieceL2 then
        pieceL3
    else if p == pieceL3 then
        pieceL4
    else if p == pieceL4 then
        pieceL1
    else if p == pieceS1 then
        pieceS2
    else if p == pieceS2 then
        pieceS1
    else if p == pieceT1 then
        pieceT2
    else if p == pieceT2 then
        pieceT3
    else if p == pieceT3 then
        pieceT4
    else if p == pieceT4 then
        pieceT1
    else if p == pieceZ1 then
        pieceZ2
    else if p == pieceZ2 then
        pieceZ1
    else
        Debug.crash "Should be exhaustive"


newPiece : Int -> Piece
newPiece rn =
    case rn % 7 of
        0 ->
            pieceI1

        1 ->
            pieceO

        2 ->
            pieceJ1

        3 ->
            pieceL1

        4 ->
            pieceS1

        5 ->
            pieceT1

        6 ->
            pieceZ1

        _ ->
            Debug.crash "no dependent types in Elm"
