module Others exposing (..)

import Entity exposing (..)


princess : ( Float, Float ) -> Movable (Drawable {})
princess ( x, y ) =
    { x = x
    , y = y
    , drawinfo =
        { fill =
            Sprite
                { hasRun = True
                , hasJump = True
                , hasLeftRight = True
                , spriteName = "mario"
                }
        , width = 30
        , height = 30
        }
    , dx = 0
    , dy = 0
    , w = 30
    , h = 30
    , state = Standing
    , onGround = True
    , dir = Left
    , squish = 0
    }
