module Archive exposing (defaultSelectedPath, maxTreeDepth, pathHeader, treeExample)

import Tree exposing (Tree, tree)


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
    [ "2017", "parties", "waddle-on", "town.swf" ]
