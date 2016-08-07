module StoryView exposing (storyView, tetrisBlocksWithWalls)

import Collage exposing (Form, collage, toForm, rect, filled, move, scale)
import Element exposing (show, Element, image)
import Text
import Color exposing (Color, rgb)
import Tetris exposing (onSpots, boardCols, boardRows, TetrisState)
import Entity exposing (Drawable, Directional(..), EntityState(..), drawInfoColor)


storyView world =
    Element.toHtml
        (collage 400
            400
            ([ -- Collage.text (Text.fromString (toString world)),
               draw ( world.sf, world.player.x, world.player.y ) world.player
             ]
                ++ (List.map (draw ( world.sf, world.player.x, world.player.y )) (displayBlocks world.tetris))
                ++ (List.map (draw ( world.sf, world.player.x, world.player.y )) (displayWalls walls))
            )
        )


displayBlocks : TetrisState -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState }
displayBlocks tetris =
    tetrisBlocks tetris
        |> List.map (xywhToDrawable (rgb 0 200 0))


displayWalls : List { x : Float, y : Float, w : Float, h : Float } -> List { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState }
displayWalls walls =
    List.map (xywhToDrawable (rgb 100 0 0)) walls


xywhToDrawable : Color -> { x : Float, y : Float, w : Float, h : Float } -> { drawinfo : Entity.DrawInfo, x : Float, y : Float, dir : Directional, state : EntityState }
xywhToDrawable color { x, y, w, h } =
    { x = x
    , y = y
    , drawinfo = drawInfoColor color w h
    , dir = Neither
    , state = Standing
    }


tetrisBlocks tetris =
    tetris
        |> onSpots
        |> List.map (\( x, y ) -> { x = toFloat x * 100 - 50, y = toFloat y * 100 - 50, w = 100.0, h = 100.0 })


tetrisBlocksWithWalls tetris =
    (tetrisBlocks tetris) ++ walls


walls =
    [ { x = (boardCols / 2) * 100
      , y = toFloat -50
      , w = toFloat (100 * (boardCols + 2))
      , h = toFloat 100
      }
    , { x = (boardCols / 2) * 100
      , y = toFloat (boardRows * 100) + 50
      , w = toFloat (100 * (boardCols + 2))
      , h = toFloat 100
      }
    ]


drawSolid : ( Float, Float, Float, Float ) -> Color -> Form
drawSolid ( x, y, w, h ) color =
    rect w h
        |> filled color
        |> move ( x, y )



-- At position scale factor 1, entire width of tetris fits onscreen.
-- place player at 1/3 down the screen
-- once fully zoomed out, stop following player
-- given a scale, center, and a width and height, draw the thing


draw : ( Float, Float, Float ) -> Drawable a -> Form
draw ( sf, cx, cy ) entity =
    let
        x =
            (entity.x - cx) * sf

        y =
            (entity.y - cy) * sf

        w =
            (entity.drawinfo.width * sf)

        h =
            (entity.drawinfo.height * sf)
    in
        case entity.drawinfo.fill of
            Entity.Sprite spriteInfo ->
                spriteDraw ( x, y, w, h ) spriteInfo entity

            Entity.Solid solidInfo ->
                drawSolid ( x, y, w, h ) solidInfo


spriteDraw : ( Float, Float, Float, Float ) -> Entity.SpriteInfo -> Drawable a -> Form
spriteDraw ( x, y, w, h ) spriteInfo entity =
    let
        verb =
            if spriteInfo.hasRun || spriteInfo.hasJump then
                case entity.state of
                    Standing ->
                        "/stand"

                    Jumping ->
                        if spriteInfo.hasJump then
                            "/jump"
                        else
                            "/stand"

                    Running ->
                        if spriteInfo.hasRun then
                            "/walk"
                        else
                            "/stand"
            else
                ""

        dir =
            if spriteInfo.hasLeftRight then
                case entity.dir of
                    Left ->
                        "/left"

                    Right ->
                        "/right"

                    Neither ->
                        ""
            else
                ""

        root =
            "http://localhost:8080/imgs/"

        src =
            root ++ spriteInfo.spriteName ++ verb ++ dir ++ ".gif"

        entityImage =
            image (round w) (round h) src
    in
        (entityImage
            |> toForm
            |> move ( x, y )
        )
