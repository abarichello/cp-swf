port module Main exposing (Msg(..), main, update, view)

import Archive
    exposing
        ( Archive
        , Node(..)
        , archiveDecoder
        , defaultFocusedNode
        , defaultSWFPath
        , defaultSelectedPath
        , emptyArchive
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
import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser
import Color
import Html exposing (Attribute, Html, b, button, div, embed, text, u)
import Html.Attributes exposing (class, href, id, src, style)
import Html.Events exposing (onClick)
import Json.Decode exposing (decodeString)
import List.Extra as ListExtra
import Requests exposing (ArchiveJSON(..), fetchArchive)
import Url
import Utils exposing (defaultURL, errorToString)


type alias Model =
    { archive : Archive
    , selectedPath : List String
    , focusedNode : Node
    , loadedPath : String
    , navbarState : Navbar.State
    , modalVisibility : Modal.Visibility
    , debug : Bool
    }


type Msg
    = None
    | RequestArchive ArchiveJSON
    | ResetTree
    | TraverseTree String
    | LoadFileFromQuery String
    | NavbarMsg Navbar.State
    | ToggleModal Modal.Visibility


port urlReceiver : (String -> msg) -> Sub msg


port sendSetPageQuery : String -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    urlReceiver LoadFileFromQuery


main : Program Bool Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Bool -> ( Model, Cmd Msg )
init debug =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        archiveRequest =
            Cmd.map RequestArchive (Requests.fetchArchive debug)
    in
    ( { archive = emptyArchive
      , selectedPath = defaultSelectedPath
      , loadedPath = defaultSWFPath
      , focusedNode = defaultFocusedNode
      , navbarState = navbarState
      , modalVisibility = Modal.shown
      , debug = debug
      }
    , Cmd.batch [ navbarCmd, archiveRequest ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        RequestArchive response ->
            case response of
                JSON result ->
                    let
                        res =
                            case result of
                                Ok value ->
                                    value

                                Err err ->
                                    errorToString err

                        archive =
                            decodeString archiveDecoder res
                                |> Result.toMaybe
                                |> Maybe.withDefault emptyArchive
                    in
                    ( { model | archive = archive, focusedNode = rootFolder archive }, Cmd.none )

        ResetTree ->
            ( { model
                | selectedPath = []
                , focusedNode = rootFolder model.archive
              }
            , sendSetPageQuery ""
            )

        TraverseTree childName ->
            let
                lastSelectedPath =
                    ListExtra.last model.selectedPath |> Maybe.withDefault ""

                replace =
                    isSWF childName && isSWF lastSelectedPath

                focusedNode =
                    if isSWF childName then
                        model.focusedNode

                    else
                        findChild childName model.focusedNode

                selectedPath =
                    if replace then
                        let
                            uncons =
                                ListExtra.unconsLast model.selectedPath
                                    |> Maybe.withDefault ( "", [] )
                                    |> Tuple.second
                        in
                        List.append uncons [ childName ]

                    else
                        let
                            breadcrumbs =
                                -- Empty the breadcrumbs list
                                if model.selectedPath == defaultSelectedPath then
                                    []

                                else
                                    model.selectedPath
                        in
                        breadcrumbs ++ [ childName ]

                loadedPath =
                    if isSWF childName then
                        makeSWFPath selectedPath

                    else
                        model.loadedPath

                cmd =
                    if isSWF childName then
                        sendSetPageQuery (loadedPath |> String.replace pathHeader "")

                    else
                        Cmd.none
            in
            ( { model
                | focusedNode = focusedNode
                , selectedPath = selectedPath
                , loadedPath = loadedPath
              }
            , cmd
            )

        LoadFileFromQuery url ->
            let
                query =
                    Url.fromString url
                        |> Maybe.withDefault defaultURL
                        |> .query
                        |> Maybe.withDefault ""

                loadedPath =
                    if query == "" then
                        model.loadedPath

                    else
                        query
                            |> String.dropLeft 5
                            |> String.append pathHeader
            in
            ( { model | loadedPath = loadedPath }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ToggleModal vis ->
            ( { model | modalVisibility = vis }, Cmd.none )


oppositeModalVisibility : Model -> Modal.Visibility
oppositeModalVisibility model =
    if model.modalVisibility == Modal.shown then
        Modal.hidden

    else
        Modal.shown


modalVisibilityStyle : Model -> Attribute msg
modalVisibilityStyle model =
    if model.modalVisibility == Modal.shown then
        style "display" "flex"

    else
        style "display" "none"


view : Model -> Html Msg
view model =
    let
        navbarItems =
            [ Navbar.itemLink [ onClick (ToggleModal (oppositeModalVisibility model)), href "#" ] [ text "Files" ]
            , Navbar.itemLink [ href "https://gitlab.com/BARICHELLO/cp-swf-archive" ] [ text "Archive" ]
            , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf" ] [ text "Source code" ]
            , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/LICENSE" ] [ text "License" ]
            , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/README.md" ] [ text "About" ]
            ]

        fileCounter =
            div [ class "nav-link font-weight-bold text-light" ]
                [ text "Total archived files: "
                , Badge.pillLight [] [ text (String.fromInt (rootReportTotalFiles model.archive)) ]
                ]

        navbar =
            Navbar.config NavbarMsg
                |> Navbar.withAnimation
                |> Navbar.attrs [ id "navbar" ]
                |> Navbar.darkCustom (Color.rgb255 0 51 102)
                |> Navbar.brand [ href "#" ] [ text "CP-SWF" ]
                |> Navbar.items navbarItems
                |> Navbar.customItems [ Navbar.customItem fileCounter ]
                |> Navbar.view model.navbarState

        modalHeader =
            Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col
                        [ Col.xs6 ]
                        [ text "Files" ]
                    ]
                ]

        modalBody =
            let
                breadcrumbs =
                    if model.selectedPath == defaultSelectedPath then
                        ""

                    else
                        makePath model.selectedPath

                children =
                    focusedChildren model.focusedNode
                        |> List.map (\node -> nodeToString node)
                        |> List.filter (\label -> not (isLabelExcluded label))
                        |> List.map
                            (\str ->
                                div [ class "dir-link", onClick (TraverseTree str) ]
                                    [ text
                                        (if isDir str then
                                            str ++ "/"

                                         else
                                            str
                                        )
                                    ]
                            )
                        |> List.append [ u [] [ b [] [ text breadcrumbs ] ] ]
            in
            div [ id "file-list" ] children

        modalFooter =
            Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col [ Col.xs ]
                        [ Button.button
                            [ Button.outlineLight
                            , Button.attrs [ id "reset-button", onClick ResetTree ]
                            ]
                            [ text "Reset" ]
                        ]
                    , Grid.col [ Col.xs ]
                        [ Button.button
                            [ Button.outlineLight
                            , Button.attrs [ id "hide-button", onClick (ToggleModal Modal.hidden) ]
                            ]
                            [ text "Hide" ]
                        ]
                    ]
                ]

        dirModal =
            Grid.container [ modalVisibilityStyle model ]
                [ Modal.config None
                    |> Modal.small
                    |> Modal.h5 [] [ modalHeader ]
                    |> Modal.body [] [ modalBody ]
                    |> Modal.footer [] [ modalFooter ]
                    |> Modal.view model.modalVisibility
                ]
    in
    div [ id "main" ]
        [ navbar
        , dirModal
        , div [ id "swf-content" ]
            [ embed [ id "swf", src model.loadedPath ] []
            ]
        ]
