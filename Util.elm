module Util exposing (range)


range max =
    List.indexedMap (\i x -> i) (List.repeat max 0)
