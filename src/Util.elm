module Util exposing (range)


range : Int -> List Int
range max =
    List.indexedMap (\i x -> i) (List.repeat max 0)
