module Archive exposing
    ( Archive
    , Node(..)
    , archiveDecoder
    , defaultBreadcrumbs
    , defaultFocusedNode
    , defaultSWFPath
    , emptyArchive
    , excludedExtensions
    , findChild
    , focusedChildren
    , isDir
    , isLabelExcluded
    , isSWF
    , makePath
    , makeSWFPath
    , nodeToString
    , pathHeader
    , rootFolder
    , rootReportTotalFiles
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field
import List exposing (intersperse)
import List.Extra as ListExtra
import Utils exposing (listToString)


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
                    Decode.fail "Could not decode invalid node type"


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


nodeToString : Node -> String
nodeToString node =
    case node of
        Directory dir ->
            dir.name

        File name ->
            name

        Report _ ->
            ""


rootFolder : Archive -> Node
rootFolder archive =
    -- Only works when used at the root archive
    archive
        |> List.head
        |> Maybe.withDefault defaultFocusedNode


rootReportTotalFiles : Archive -> Int
rootReportTotalFiles archive =
    -- Only works when used at the root archive
    let
        node =
            archive
                |> ListExtra.last
                |> Maybe.withDefault defaultFocusedNode
    in
    case node of
        Report r ->
            r.files

        _ ->
            0


focusedChildren : Node -> List Node
focusedChildren node =
    case node of
        Directory dir ->
            dir.contents

        _ ->
            []


findChild : String -> Node -> Node
findChild label node =
    List.filter (\child -> nodeToString child == label) (focusedChildren node)
        |> List.head
        |> Maybe.withDefault defaultFocusedNode


isLabelExcluded : String -> Bool
isLabelExcluded label =
    let
        extension =
            label
                |> String.split "."
                |> ListExtra.last
                |> Maybe.withDefault ""
    in
    List.member extension excludedExtensions


excludedExtensions : List String
excludedExtensions =
    [ "json", "md" ]


makePath : List String -> String
makePath list =
    list
        |> List.intersperse "/"
        |> listToString


makeSWFPath : List String -> String
makeSWFPath list =
    list
        |> makePath
        |> String.append pathHeader


isSWF : String -> Bool
isSWF str =
    String.endsWith ".swf" str


isDir : String -> Bool
isDir str =
    not (String.contains "." str)


pathHeader : String
pathHeader =
    "./cp-swf-archive/"


defaultBreadcrumbs : List String
defaultBreadcrumbs =
    [ "2017"
    , "parties"
    , "waddle-on"
    , "town.swf"
    ]


defaultSWFPath : String
defaultSWFPath =
    makeSWFPath defaultBreadcrumbs


defaultFocusedNode : Node
defaultFocusedNode =
    Report { directories = 0, files = 0 }


emptyArchive : Archive
emptyArchive =
    [ Directory
        { name = "."
        , contents =
            [ File "empty-archive"
            ]
        }
    , defaultFocusedNode
    ]
