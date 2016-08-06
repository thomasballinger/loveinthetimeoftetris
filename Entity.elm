module Entity exposing (..)

import StoryView exposing (Directional(..))
import Color exposing (Color, rgb)


type EntityState
    = Standing
    | Jumping
    | Running


type alias Drawable x =
    { x | x : Float, y : Float, drawinfo : DrawInfo, state : EntityState, dir : Directional }


type alias DrawInfo =
    { hasStand : Bool, hasJump : Bool, hasLeftRight : Bool, spriteName : String, color : Color, width : Float, height : Float }


type alias Movable x =
    { x | x : Float, y : Float, dx : Float, dy : Float }


type alias Standable x =
    { x | heightToCenter : Float }


type alias Collidable x =
    { x | width : Float, height : Float, x : Float, y : Float }


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


initialPlayer x y =
    { x = x
    , y = y
    , drawinfo =
        { hasStand = True
        , hasJump = True
        , hasLeftRight = True
        , spriteName = "mario"
        , color = rgb 10 10 10
        , width = 30
        , height = 30
        }
    , dx = 0
    , dy = 0
    , heightToCenter = 10
    , width = 30
    , height = 30
    , state = Standing
    , dir = Left
    }


type CollisionType
    = Floor
    | Ceiling
    | LeftWall
    | RightWall
    | None


type alias Collision =
    ( CollisionType, Float )


wallCollide : List (Collidable a) -> Collidable (Standable b) -> Collision
wallCollide entity walls =
    ( None, 0 )


wallAlter : Drawable (Movable a) -> Collision -> Drawable (Movable a)
wallAlter entity collision =
    case collision of
        ( Floor, n ) ->
            { entity | dy = 0, state = Standing }

        ( Ceiling, n ) ->
            { entity | dy = 0 }

        ( LeftWall, n ) ->
            { entity | dx = 0, x = entity.x + n + 1 }

        ( RightWall, n ) ->
            { entity | dx = 0, x = entity.x - n - 1 }

        ( None, _ ) ->
            entity



--- need squishing for when top and bottom both collide
