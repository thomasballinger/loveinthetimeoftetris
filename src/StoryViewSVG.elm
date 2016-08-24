module StoryViewSVG exposing (storyViewSVG)

import Html
import Svg exposing (..)
import Svg.Attributes as Atts
import Progression exposing (Model)
import Entity exposing (Drawable)
import Tetris exposing (TetrisState, displayBlocks, displayWalls, walls)


storyViewSVG : ( Int, Int ) -> Model -> Html.Html msg
storyViewSVG ( w, h ) model =
    svg [ Atts.width (toString w), Atts.height (toString h), Atts.viewBox "-0.5 -0.5 1 1" ]
        ((List.map (draw ( w, h, Progression.sf model, model.player.x, model.player.y ))
            [ model.player ]
         )
            ++ (List.map (draw ( w, h, Progression.sf model, model.player.x, model.player.y ))
                    (displayWalls walls)
               )
            ++ (List.map (draw ( w, h, Progression.sf model, model.player.x, model.player.y )) (displayBlocks model.tetris))
        )


draw : ( Int, Int, Float, Float, Float ) -> Drawable a -> Svg msg
draw ( ww, wh, sf, cx, cy ) entity =
    let
        sfx =
            sf / (toFloat ww)

        sfy =
            sf / (toFloat wh)

        w =
            (entity.drawinfo.width * sfx)

        h =
            (entity.drawinfo.height * sfy)

        x =
            (entity.x - cx) * sfx - (w / 2)

        y =
            (cy - entity.y) * sfy - (h / 2)
    in
        rect
            [ Atts.x (toString x)
            , Atts.y (toString y)
            , Atts.width (toString w)
            , Atts.height (toString h)
            ]
            []
