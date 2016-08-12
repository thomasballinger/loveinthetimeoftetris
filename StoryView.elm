module StoryView exposing (storyView)

import Collage exposing (Form, collage, toForm, rect, filled, move, moveX, moveY, scale)
import Element exposing (show, Element, image)
import Text
import Color exposing (Color, rgb)
import Tetris exposing (TetrisState, displayBlocks, displayWalls, walls)
import Entity exposing (Drawable, Directional(..), EntityState(..), drawInfoColor)


entities world =
    [ world.player ] ++ world.others


storyView w h world =
    Element.toHtml
        (collage w
            h
            ((List.map (draw ( world.sf, world.player.x, world.player.y )) (entities world))
                ++ (List.map (draw ( world.sf, world.player.x, world.player.y )) (displayBlocks world.tetris))
                ++ (List.map (draw ( world.sf, world.player.x, world.player.y )) (displayWalls walls))
                ++ (if world.tetrisControlsActivated then
                        [ Collage.text (Text.fromString "Tetris Controls: IJKL") |> move ( 0, ((toFloat h) / 2) - 10 ) ]
                    else
                        [ Collage.text (Text.fromString "Controls: WASD") |> move ( 0, ((toFloat h) / 2) - 10 ) ]
                   )
            )
        )


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
                case ( entity.state, entity.onGround ) of
                    ( _, False ) ->
                        if spriteInfo.hasJump then
                            "/jump"
                        else
                            "/stand"

                    ( Standing, True ) ->
                        "/stand"

                    ( Running, True ) ->
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
            |> moveY -(h / 8)
         -- hardcoding player's feet to the ground
        )
