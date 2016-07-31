module StoryView exposing (storyView, Directional(..))

import Collage exposing (collage, toForm, rect, filled, move, scale)
import Element exposing (show, Element, image)
import Text
import Color exposing (rgb)
import Tetris exposing (onSpots, boardCols, boardRows)


storyView world =
    Element.toHtml
        (collage 400
            400
            ([ -- Collage.text (Text.fromString (toString world)),
               playerDisplay ( world.sf, world.player.x, world.player.y ) world.player
             ]
                ++ (List.map (rectForm ( world.sf, world.player.x, world.player.y )) (blocks world.tetris))
                ++ (List.map (rectForm ( world.sf, world.player.x, world.player.y )) walls)
            )
        )


type alias EntityRect number =
    { x : number
    , y : number
    , width : number
    , height : number
    }


type Directional
    = Left
    | Right


blocks tetris =
    List.map
        (\( x, y ) ->
            { width = toFloat 100
            , height = toFloat 100
            , x = toFloat (x * 100 - 50)
            , y = toFloat (y * 100 - 50)
            }
        )
        (onSpots tetris)


walls =
    [ { width = toFloat (100 * (boardCols + 2))
      , height = 100
      , x = (boardCols / 2) * 100
      , y = -50
      }
    , { width = toFloat (100 * (boardCols + 2))
      , height = 100
      , x = (boardCols / 2) * 100
      , y = (boardRows) * 100 + 50
      }
    ]


rectForm ( sf, cx, cy ) entityRect =
    rect (entityRect.width * sf) (entityRect.height * sf)
        |> filled (rgb 10 30 50)
        |> move ( (entityRect.x - cx) * sf, (entityRect.y - cy) * sf )



-- At position scale factor 1, entire width of tetris fits onscreen.
-- place player at 1/3 down the screen
-- once fully zoomed out, stop following player
-- given a scale, center, and a width and height, draw the thing


playerDisplay ( sf, cx, cy ) player =
    let
        verb =
            if player.y > 0 then
                "jump"
            else if player.dx /= 0 then
                "walk"
            else
                "stand"

        dir =
            case player.dir of
                Left ->
                    "left"

                Right ->
                    "right"

        src =
            "http://elm-lang.org/imgs/mario/" ++ verb ++ "/" ++ dir ++ ".gif"

        playerImage =
            image 35 35 src
    in
        (playerImage
            |> toForm
            |> scale sf
            |> move ( (player.x - cx) * sf, (player.y - cy) * sf )
        )
