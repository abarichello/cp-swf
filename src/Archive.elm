module Archive exposing (..)

import Tree exposing (Tree, tree)


testStringLists : List String
testStringLists =
    -- [ ".", "2017", "parties", "waddle-on", "town.swf" ]
    [ ".", "2017", "parties", "waddle-on", "cove.swf" ]


treeExample : Tree String
treeExample =
    tree "."
        [ tree "2016"
            [ tree "parties" []
            ]
        , tree "2017"
            [ tree "parties"
                [ tree "default" []
                , tree "waddle-on"
                    [ tree "town.swf" []
                    , tree "cove.swf" []
                    ]
                ]
            , tree "misc"
                [ tree "telescope"
                    [ tree "telescope.swf" []
                    ]
                ]
            ]
        ]


maxTreeDepth : Int
maxTreeDepth =
    4


pathHeader : String
pathHeader =
    "./cp-swf-archive/"


defaultSelectedPath : List String
defaultSelectedPath =
    List.append [ pathHeader ] [ "2017", "waddle-on", "town.swf" ]
