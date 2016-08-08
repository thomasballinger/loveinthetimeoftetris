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
    { x | x : Float, y : Float, drawinfo : DrawInfo, dir : Directional, state : EntityState, onGround : Bool }


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


type alias Movable x =
    { x | x : Float, y : Float, dx : Float, dy : Float, dir : Directional, onGround : Bool }


type alias Standable x =
    { x | heightToCenter : Float }


type alias Collidable x =
    { x | w : Float, h : Float, x : Float, y : Float }


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
    , heightToCenter = 10
    , w = 30
    , h = 30
    , state = Standing
    , onGround = True
    , dir = Left
    }


type CollisionType
    = Floor
    | Ceiling
    | LeftWall
    | RightWall


type PossibleCollision
    = NoCollision
    | Collision CollisionType Float



--- TODO: To choose which collision to report, find the dimension that overlaps most!


collisionIf : CollisionType -> Float -> PossibleCollision
collisionIf direction overlap =
    if overlap > 0 then
        Collision direction overlap
    else
        NoCollision


smallestCollision : Collidable (Standable b) -> Collidable a -> PossibleCollision
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

        bottomDist =
            collisionIf Floor (top2 - bottom1)

        topDist =
            collisionIf Ceiling (top1 - bottom2)

        leftDist =
            collisionIf LeftWall (right2 - left1)

        rightDist =
            collisionIf RightWall (right1 - left2)

        touching =
            not
                ((left2 >= right1)
                    || (right2 <= left1)
                    || (top2 <= bottom1)
                    || (bottom2 >= top1)
                )
    in
        if touching then
            let
                collisions =
                    List.sortBy
                        (\x ->
                            case x of
                                Collision _ amount ->
                                    amount

                                NoCollision ->
                                    0
                        )
                        (List.filter
                            (\x ->
                                case x of
                                    Collision _ amount ->
                                        amount > 0

                                    NoCollision ->
                                        False
                            )
                            [ bottomDist, topDist, leftDist, rightDist ]
                        )
            in
                case List.head collisions of
                    Nothing ->
                        NoCollision

                    Just c ->
                        c
        else
            NoCollision



-- Collision strategy:
-- Repeatedly find smallest collision, correct for it, then get next collision


wallAlter : Collidable (Movable a) -> PossibleCollision -> Collidable (Movable a)
wallAlter entity collision =
    case collision of
        Collision Floor n ->
            { entity | dy = -1, y = entity.y + n, onGround = True }

        Collision Ceiling n ->
            { entity | dy = min 0 entity.dy, y = entity.y - n }

        Collision LeftWall n ->
            { entity | dx = 0, x = entity.x + n }

        Collision RightWall n ->
            { entity | dx = 0, x = entity.x - n }

        _ ->
            entity


wallCollision : List (Collidable a) -> Collidable (Standable b) -> PossibleCollision
wallCollision walls entity =
    case walls of
        [] ->
            NoCollision

        wall :: rest ->
            case smallestCollision entity wall of
                NoCollision ->
                    wallCollision rest entity

                collision ->
                    collision


doCollisions : List (Collidable a) -> Collidable (Standable (Movable b)) -> Collidable (Standable (Movable b))
doCollisions walls entity =
    let
        first =
            wallCollision walls entity

        e2 =
            wallAlter entity first

        second =
            wallCollision walls e2

        e3 =
            wallAlter e2 second
    in
        e3



--- need squishing for when top and bottom both collide
