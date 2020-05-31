module Main exposing (Msg(..), main, update, view)

import Archive exposing (defaultSelectedPath, maxTreeDepth, pathHeader, treeExample)
import Bootstrap.Navbar as Navbar
import Browser
import Color exposing (Color)
import Html exposing (Html, button, div, embed, li, text)
import Html.Attributes exposing (height, href, id, src, width)
import Html.Events exposing (onClick)
import Tree exposing (Tree, label)
import Tree.Zipper exposing (Zipper, findNext, fromTree)
import Utils exposing (listToString)


type alias Model =
    { tree : Tree String
    , zipper : Zipper String
    , selectedPath : List String
    , loadedPath : String
    , navbarState : Navbar.State
    }


type Msg
    = ResetTree
    | TraverseTree String
    | LoadSWF
    | NavbarMsg Navbar.State


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
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( { tree = treeExample
      , zipper = fromTree treeExample
      , selectedPath = defaultSelectedPath
      , loadedPath = "./cp-swf-archive/2017/parties/waddle-on/town.swf"
      , navbarState = navbarState
      }
    , navbarCmd
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

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )


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

        navbar =
            Navbar.config NavbarMsg
                |> Navbar.withAnimation
                |> Navbar.darkCustom (Color.rgb255 0 51 102)
                |> Navbar.brand [ href "#" ] [ text "CP-SWF" ]
                |> Navbar.items
                    [ Navbar.itemLink [ href "https://gitlab.com/BARICHELLO/cp-swf-archive" ] [ text "Archive" ]
                    , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf" ] [ text "Source code" ]
                    , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/LICENSE" ] [ text "License" ]
                    , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/README.md" ] [ text "About" ]
                    ]
                |> Navbar.view model.navbarState
    in
    div []
        [ navbar
        , div [ id "selector-header" ] [ button [ id "reset-tree", onClick ResetTree ] [ text "Reset" ] ]
        , div [ id "swf-content" ]
            [ embed [ id "swf", src model.loadedPath, width 2560, height 1440 ] []
            ]
        ]
