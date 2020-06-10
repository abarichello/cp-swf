module Archive exposing
    ( Archive
    , archiveDecoder
    , defaultSelectedPath
    , emptyArchive
    , maxTreeDepth
    , pathHeader
    , testStringLists
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field


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
    --
    [ [ "2017", "parties", "waddle-on", "town.swf" ]
    , [ "2017", "parties", "waddle-on", "cove.swf" ]
    , [ "2017", "parties", "waddle-on", "skivillage.swf" ]
    , [ "2017", "parties", "default", "town.swf" ]
    , [ "2016", "parties", "default", "dock.swf" ]
    ]


type alias Archive =
    List Node


type Node
    = Directory { name : String, contents : List Node }
    | File String
    | Report { directories : Int, files : Int }


archiveDecoder : Decoder Archive
archiveDecoder =
    Decode.list nodeDecoder


nodeDecoder : Decoder Node
nodeDecoder =
    Field.require "type" Decode.string <|
        \t ->
            case t of
                "directory" ->
                    directoryDecoder

                "file" ->
                    fileDecoder

                "report" ->
                    reportDecoder

                _ ->
                    Decode.fail "Invalid node"


directoryDecoder : Decoder Node
directoryDecoder =
    Field.require "name" Decode.string <|
        \name ->
            Field.require "contents" (Decode.list nodeDecoder) <|
                \contents ->
                    Decode.succeed <|
                        Directory
                            { name = name
                            , contents = contents
                            }


fileDecoder : Decoder Node
fileDecoder =
    Field.require "name" Decode.string <| \name -> Decode.succeed (File name)


reportDecoder : Decoder Node
reportDecoder =
    Field.require "directories" Decode.int <|
        \directories ->
            Field.require "files"
                Decode.int
            <|
                \files ->
                    Decode.succeed
                        (Report { directories = directories, files = files })


emptyArchive : Archive
emptyArchive =
    [ Directory
        { name = "."
        , contents =
            [ File "empty-archive"
            ]
        }
    , Report { directories = 1, files = 1 }
    ]
