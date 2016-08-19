module Entity exposing (..)

import Color exposing (Color, rgb)


type EntityState
    = Standing
    | Running


type Directional
    = Left
    | Right
    | Neither


type alias Drawable x =
    { x | x : Float, y : Float, drawinfo : DrawInfo, dir : Directional, state : EntityState, onGround : Bool, squish : Float }


type alias DrawInfo =
    { fill : Fill, width : Float, height : Float }


drawInfoColor : Color -> Float -> Float -> DrawInfo
drawInfoColor color w h =
    { fill = Solid color
    , width = w
    , height = h
    }


type Fill
    = Sprite SpriteInfo
    | Solid Color


type alias SpriteInfo =
    { hasRun : Bool
    , hasJump : Bool
    , hasLeftRight : Bool
    , spriteName : String
    }


type alias Movable a =
    { a | x : Float, y : Float, dx : Float, dy : Float, w : Float, h : Float }


gravity : Float -> Movable a -> Movable a
gravity dt entity =
    { entity | dy = entity.dy - 1 * dt }



-- Hack because of somethign I don't understand:
-- https://gist.github.com/thomasballinger/a0d8b38fa7186ee2e608d4772f2ebe7e
-- for now I'm annotating this a bunch more.


step : Float -> Movable a -> Movable a
step dt entity =
    { entity
        | x = entity.x + entity.dx * dt
        , y = entity.y + entity.dy * dt
    }


nopCompilerHack : { a | dir : Directional, dx : Float, dy : Float, x : Float, y : Float } -> { a | dir : Directional, dx : Float, dy : Float, x : Float, y : Float }
nopCompilerHack x =
    x


collide : Movable a -> Movable b -> Bool
collide e1 e2 =
    False


initialPlayer : ( Float, Float ) -> Movable (Drawable {})
initialPlayer ( x, y ) =
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
    , w = 15
    , h = 30
    , state = Standing
    , onGround = True
    , dir = Left
    , squish = 0
    }


type CollisionType
    = Floor
    | Ceiling
    | LeftWall
    | RightWall


type alias Collision =
    { collisionType : CollisionType, overlap : Float, velocity : ( Float, Float ) }


maybeCollision : CollisionType -> Float -> ( Float, Float ) -> Maybe Collision
maybeCollision direction overlap velocity =
    if overlap > 0 then
        Just (Collision direction overlap velocity)
    else
        Nothing


smallestCollision : Movable b -> Movable a -> Maybe Collision
smallestCollision e w =
    let
        left1 =
            e.x - e.w / 2

        right1 =
            e.x + e.w / 2

        bottom1 =
            e.y - e.h / 2

        top1 =
            e.y + e.h / 2

        left2 =
            w.x - w.w / 2

        right2 =
            w.x + w.w / 2

        bottom2 =
            w.y - w.h / 2

        top2 =
            w.y + w.h / 2

        touching =
            not
                ((left2 >= right1)
                    || (right2 <= left1)
                    || (top2 <= bottom1)
                    || (bottom2 >= top1)
                )
    in
        if not touching then
            Nothing
        else
            (List.map3 maybeCollision
                [ Floor, Ceiling, LeftWall, RightWall ]
                [ (top2 - bottom1), (top1 - bottom2), (right2 - left1), (right1 - left2) ]
                [ ( w.dx, w.dy ), ( w.dx, w.dy ), ( w.dx, w.dy ), ( w.dx, w.dy ) ]
            )
                |> List.filterMap (\x -> x)
                |> List.sortBy .overlap
                |> List.head



-- Collision strategy:
-- Repeatedly find smallest collision, correct for it, then get next collision


wallAlter : Drawable (Movable a) -> Maybe Collision -> Drawable (Movable a)
wallAlter entity collision =
    case collision of
        Nothing ->
            entity

        Just col ->
            case ( col.collisionType, col.velocity ) of
                ( Floor, ( vx, vy ) ) ->
                    { entity | dy = (1 * vy) - 0.001, y = entity.y + col.overlap, onGround = True }

                ( Ceiling, ( vx, vy ) ) ->
                    { entity | dy = min 0 entity.dy, y = entity.y - col.overlap }

                ( LeftWall, ( vx, vy ) ) ->
                    { entity | dx = vx, x = entity.x + col.overlap }

                ( RightWall, ( vx, vy ) ) ->
                    { entity | dx = vx, x = entity.x - col.overlap }


firstWallCollision : List (Movable a) -> Movable b -> Maybe Collision
firstWallCollision walls entity =
    case walls of
        [] ->
            Nothing

        wall :: rest ->
            case smallestCollision entity wall of
                Nothing ->
                    firstWallCollision rest entity

                Just collision ->
                    Just collision


doCollisions : List (Movable a) -> Drawable (Movable b) -> Drawable (Movable b)
doCollisions walls entity =
    let
        first =
            Debug.log "first collision:" (firstWallCollision walls entity)

        e2 =
            wallAlter entity first

        second =
            firstWallCollision walls e2

        e3 =
            wallAlter e2 second

        third =
            firstWallCollision walls e3
    in
        crushCheck e3 first second third


crushCheck : Movable (Drawable b) -> Maybe Collision -> Maybe Collision -> Maybe Collision -> Movable (Drawable b)
crushCheck e c1 c2 c3 =
    case ( c1, c2, c3 ) of
        ( Nothing, Nothing, _ ) ->
            e

        ( Nothing, _, _ ) ->
            e

        ( _, Nothing, _ ) ->
            e

        ( Just col1, Just col2, Nothing ) ->
            if ((col1.collisionType == Floor && col2.collisionType == Ceiling) || (col1.collisionType == Ceiling && col2.collisionType == Floor)) then
                { e | squish = 1.0 }
            else if ((col1.collisionType == LeftWall && col2.collisionType == RightWall) || (col1.collisionType == LeftWall && col2.collisionType == RightWall)) then
                { e | squish = -1.0 }
            else
                e

        ( Just col1, Just col2, Just col3 ) ->
            let
                thing =
                    Debug.log "three collisions:" ( col1, col2, col3 )
            in
                case col3.collisionType of
                    Floor ->
                        { e | squish = 1.0 }

                    Ceiling ->
                        { e | squish = 1.0 }

                    LeftWall ->
                        { e | squish = -1.0 }

                    RightWall ->
                        { e | squish = -1.0 }
