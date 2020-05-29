module Main exposing (Msg(..), main, update, view)

import Archive exposing (defaultSelectedPath, maxTreeDepth, pathHeader, treeExample)
import Browser
import Html exposing (Html, button, div, embed, li, text)
import Html.Attributes exposing (height, id, src, width)
import Html.Events exposing (onClick)
import Tree exposing (Tree, label)
import Tree.Zipper exposing (Zipper, findNext, fromTree)
import Utils exposing (listToString)


type alias Model =
    { tree : Tree String
    , zipper : Zipper String
    , selectedPath : List String
    , loadedPath : String
    }


type Msg
    = ResetTree
    | TraverseTree String
    | LoadSWF


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    ( { tree = treeExample
      , zipper = fromTree treeExample
      , selectedPath = defaultSelectedPath
      , loadedPath = "./cp-swf-archive/2017/parties/waddle-on/town.swf"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResetTree ->
            ( { model
                | zipper = fromTree treeExample
                , selectedPath = defaultSelectedPath
              }
            , Cmd.none
            )

        TraverseTree child ->
            let
                zipperChild =
                    findNext (\c -> c == child) model.zipper

                selectedPath =
                    if List.length model.selectedPath == maxTreeDepth then
                        [ child ]

                    else
                        List.append model.selectedPath [ child ]

                loadedPath =
                    if String.endsWith ".swf" child then
                        let
                            tmpModel =
                                { model | selectedPath = selectedPath }
                        in
                        makeSWFPath tmpModel

                    else
                        model.loadedPath
            in
            ( { model
                | zipper = Maybe.withDefault model.zipper zipperChild
                , selectedPath = selectedPath
                , loadedPath = loadedPath
              }
            , Cmd.none
            )

        LoadSWF ->
            ( { model | loadedPath = makeSWFPath model }, Cmd.none )


makeSWFPath : Model -> String
makeSWFPath model =
    let
        list =
            List.intersperse "/" model.selectedPath
    in
    listToString list pathHeader


zipperToHtml : Zipper String -> List (Html Msg)
zipperToHtml tr =
    let
        children =
            Tree.Zipper.children tr
    in
    List.map
        (\c ->
            let
                txt =
                    label c
            in
            li [ onClick (TraverseTree txt) ] [ text txt ]
        )
        children


view : Model -> Html Msg
view model =
    let
        directoryTree =
            zipperToHtml model.zipper

        pathTxt =
            text ("Path: " ++ model.loadedPath)
    in
    div []
        [ div [ id "header" ] [ text "https://github.com/aBARICHELLO/cp-swf" ]
        , div [] (pathTxt :: directoryTree)
        , div [ id "selector-header" ] [ button [ id "reset-tree", onClick ResetTree ] [ text "Reset" ] ]
        , div [ id "swf-content" ]
            [ embed [ src model.loadedPath, width 2560, height 1440 ] []
            ]
        ]
