module Entity exposing (..)

import Color exposing (Color)


-- for sprites with left and right facing


type alias Drawable x =
    { x | x : Float, y : Float, drawinfo : DrawInfo }


type alias DrawInfo =
    { hasStand : Bool, hasJump : Bool, hasLeftRight : Bool, spriteName : String, color : Color, width : Float, height : Float }


type alias Movable x =
    { x | x : Float, y : Float, dx : Float, dy : Float }


type alias Standable x =
    { x | heightToCenter : Float }


type alias Collidable x =
    { x | width : Float, height : Float }


gravity : Float -> Movable a -> Movable a
gravity dt entity =
    { entity | dy = entity.dy - 1 * dt }


step : Float -> Movable a -> Movable a
step dt entity =
    { entity
        | x = entity.x + entity.dx * dt
        , y = entity.y + entity.dy * dt
    }


collide : Collidable a -> Collidable b -> Bool
collide e1 e2 =
    False



--- need squishing for when top and bottom both collide
