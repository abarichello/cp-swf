module Archive exposing
    ( defaultSelectedPath
    , makeArchive
    , makeTrees
    , maxTreeDepth
    , pathHeader
    , testStringLists
    )

import List.Extra exposing (getAt)
import Tree as Tree exposing (Tree, appendChild, singleton)
import Tree.Diff as Diff
import Tree.Zipper as Zipper exposing (Zipper)


maxTreeDepth : Int
maxTreeDepth =
    4


pathHeader : String
pathHeader =
    "./cp-swf-archive"


defaultSelectedPath : List String
defaultSelectedPath =
    [ "2017", "parties", "waddle-on", "town.swf" ]


testStringLists : List (List String)
testStringLists =
    [ [ "2017", "parties", "waddle-on", "town.swf" ]
    , [ "2017", "parties", "waddle-on", "cove.swf" ]
    , [ "2017", "parties", "waddle-on", "skivillage.swf" ]
    ]


makeArchive : List (List String) -> Tree String
makeArchive list =
    list |> makeTrees |> mergeTrees


makeTrees : List (List String) -> List (Tree String)
makeTrees list =
    List.map (\l -> strListToTree l) list


strListToTree : List String -> Tree String
strListToTree list =
    strListToTreeAux list (Zipper.fromTree (singleton "."))


strListToTreeAux : List String -> Zipper String -> Tree String
strListToTreeAux list zipper =
    let
        first =
            List.head list

        tail =
            Maybe.withDefault [] (List.tail list)
    in
    case first of
        Nothing ->
            Zipper.toTree zipper

        Just head ->
            let
                lastNode =
                    zipper
                        |> Zipper.lastDescendant

                res =
                    lastNode
                        |> Zipper.replaceTree (Tree.appendChild (singleton head) (lastNode |> Zipper.tree))
            in
            strListToTreeAux tail res


mergeTrees : List (Tree String) -> Tree String
mergeTrees list =
    mergeTreesAux list (singleton "cp-swf-archive")


mergeTreesAux : List (Tree String) -> Tree String -> Tree String
mergeTreesAux list acc =
    let
        firstTree =
            Maybe.withDefault (singleton "") (getAt 0 list)

        secondTree =
            getAt 1 list

        tail =
            List.drop 2 list
    in
    case secondTree of
        Nothing ->
            acc

        Just secTree ->
            mergeTreesAux tail (Diff.mergeWith equalLabels firstTree secTree)


equalLabels : String -> String -> Bool
equalLabels a b =
    a == b
