module Utils exposing (listToString)


listToString : List String -> String -> String
listToString list acc =
    let
        head =
            List.head list

        tail =
            Maybe.withDefault [] (List.tail list)
    in
    case head of
        Nothing ->
            acc

        Just el ->
            listToString tail (acc ++ el)
