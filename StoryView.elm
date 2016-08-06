module StoryView exposing (storyView)

import Collage exposing (Form, collage, toForm, rect, filled, move, scale)
import Element exposing (show, Element, image)
import Text
import Color exposing (rgb)
import Tetris exposing (onSpots, boardCols, boardRows, TetrisState)
import Entity exposing (Drawable, Directional(..), drawInfoColor)


storyView world =
    Element.toHtml
        (collage 400
            400
            ([ -- Collage.text (Text.fromString (toString world)),
               playerDisplay ( world.sf, world.player.x, world.player.y ) world.player
             ]
                ++ (List.map (drawForm ( world.sf, world.player.x, world.player.y )) (blocks world.tetris))
                ++ (List.map (drawForm ( world.sf, world.player.x, world.player.y )) walls)
            )
        )


blocks : TetrisState -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float }
blocks tetris =
    List.map
        (\( x, y ) ->
            { x = toFloat (x * 100 - 50)
            , y = toFloat (y * 100 - 50)
            , drawinfo = drawInfoColor (rgb 0 100 100) 100 100
            }
        )
        (onSpots tetris)


walls : List { drawinfo : Entity.DrawInfo, x : Float, y : Float }
walls =
    [ { drawinfo =
            (drawInfoColor (rgb 100 0 0)
                (toFloat (100 * (boardCols + 2)))
                (toFloat 100)
            )
      , x = (boardCols / 2) * 100
      , y = (toFloat -50)
      }
    , { drawinfo =
            (drawInfoColor (rgb 100 0 0)
                (toFloat (100 * (boardCols + 2)))
                (toFloat 100)
            )
      , x = (boardCols / 2) * 100
      , y = (boardRows) * 100 + 50
      }
    ]


drawForm : ( Float, Float, Float ) -> Drawable a -> Form
drawForm ( sf, cx, cy ) entity =
    rect (entity.drawinfo.width * sf) (entity.drawinfo.height * sf)
        |> filled (rgb 10 30 50)
        |> move ( (entity.x - cx) * sf, (entity.y - cy) * sf )



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
