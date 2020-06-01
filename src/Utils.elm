module Utils exposing (listToString)


listToString : List String -> String
listToString list =
    listToStringAux list ""


listToStringAux : List String -> String -> String
listToStringAux list acc =
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
            listToStringAux tail (acc ++ el)
