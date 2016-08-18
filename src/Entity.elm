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
    { a | x : Float, y : Float, dx : Float, dy : Float, dir : Directional, onGround : Bool }


type alias Standable x =
    { x | heightToCenter : Float }


type alias Collidable x =
    { x | w : Float, h : Float, x : Float, y : Float, dy : Float, dx : Float }


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


collide : Collidable a -> Collidable b -> Bool
collide e1 e2 =
    False


initialPlayer : ( Float, Float ) -> Collidable (Standable (Movable (Drawable {})))
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
    , heightToCenter = 10
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


type PossibleCollision
    = NoCollision
    | Collision CollisionType Float ( Float, Float )



--- TODO: To choose which collision to report, find the dimension that overlaps most!


collisionIf : CollisionType -> Float -> ( Float, Float ) -> PossibleCollision
collisionIf direction overlap velocity =
    if overlap > 0 then
        Collision direction overlap velocity
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
            collisionIf Floor (top2 - bottom1) ( w.dx, w.dy )

        topDist =
            collisionIf Ceiling (top1 - bottom2) ( w.dx, w.dy )

        leftDist =
            collisionIf LeftWall (right2 - left1) ( w.dx, w.dy )

        rightDist =
            collisionIf RightWall (right1 - left2) ( w.dx, w.dy )

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
                                Collision _ amount _ ->
                                    amount

                                NoCollision ->
                                    0
                        )
                        (List.filter
                            (\x ->
                                case x of
                                    Collision _ amount _ ->
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
        --TODO this should be the dy of the thing collided with
        Collision Floor n ( vx, vy ) ->
            { entity | dy = (1 * vy) - 0.001, y = entity.y + n, onGround = True }

        Collision Ceiling n ( vx, vy ) ->
            { entity | dy = min 0 entity.dy, y = entity.y - n }

        Collision LeftWall n ( vx, vy ) ->
            { entity | dx = vx, x = entity.x + n }

        Collision RightWall n ( vx, vy ) ->
            { entity | dx = vx, x = entity.x - n }

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


doCollisions : List (Collidable a) -> Collidable (Standable (Movable (Drawable b))) -> Collidable (Standable (Movable (Drawable b)))
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

        third =
            wallCollision walls e2
    in
        crushCheck e3 first second third


crushCheck : Collidable (Standable (Movable (Drawable b))) -> PossibleCollision -> PossibleCollision -> PossibleCollision -> Collidable (Standable (Movable (Drawable b)))
crushCheck e c1 c2 c3 =
    case ( c1, c2, c3 ) of
        ( NoCollision, NoCollision, _ ) ->
            e

        ( NoCollision, _, _ ) ->
            e

        ( _, NoCollision, _ ) ->
            e

        ( Collision type1 _ _, Collision type2 _ _, NoCollision ) ->
            if ((type1 == Floor && type2 == Ceiling) || (type1 == Ceiling && type2 == Floor)) then
                { e | squish = 1.0 }
            else if ((type1 == LeftWall && type2 == RightWall) || (type1 == LeftWall && type2 == RightWall)) then
                { e | squish = -1.0 }
            else
                e

        ( Collision type1 _ _, Collision type2 _ _, Collision type3 _ _ ) ->
            case type3 of
                Floor ->
                    { e | squish = 1.0 }

                Ceiling ->
                    { e | squish = 1.0 }

                LeftWall ->
                    { e | squish = -1.0 }

                RightWall ->
                    { e | squish = -1.0 }
