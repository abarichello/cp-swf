module Main exposing (Msg(..), main, update, view)

import Archive
    exposing
        ( Archive
        , Node(..)
        , archiveDecoder
        , archiveToString
        , defaultFocusedNode
        , defaultSWFPath
        , defaultSelectedPath
        , emptyArchive
        , makeSWFPath
        )
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser
import Color
import Html exposing (Html, button, div, embed, strong, text)
import Html.Attributes exposing (height, href, id, src, width)
import Html.Events exposing (onClick)
import Json.Decode exposing (decodeString)
import Requests exposing (ArchiveJSON(..), fetchArchive)
import Utils exposing (errorToString)


type alias Model =
    { archive : Archive
    , selectedPath : List String
    , focusedNode : Node
    , loadedPath : String
    , navbarState : Navbar.State
    , modalVisibility : Modal.Visibility
    }


type Msg
    = None
    | RequestArchive ArchiveJSON
    | ResetTree
    | TraverseTree String
    | LoadSWF
    | NavbarMsg Navbar.State
    | ToggleModal Modal.Visibility


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

        archiveRequest =
            Cmd.map RequestArchive Requests.fetchArchive
    in
    ( { archive = emptyArchive
      , selectedPath = defaultSelectedPath
      , loadedPath = defaultSWFPath
      , focusedNode = defaultFocusedNode
      , navbarState = navbarState
      , modalVisibility = Modal.shown
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

                        rootFolder =
                            archive |> List.head |> Maybe.withDefault defaultFocusedNode
                    in
                    ( { model | archive = archive, focusedNode = rootFolder }, Cmd.none )

        ResetTree ->
            ( { model | selectedPath = defaultSelectedPath }, Cmd.none )

        TraverseTree childName ->
            ( model
            , Cmd.none
            )

        LoadSWF ->
            ( { model | loadedPath = makeSWFPath model.selectedPath }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ToggleModal vis ->
            ( { model | modalVisibility = vis }, Cmd.none )


toggleModalVis : Model -> Modal.Visibility
toggleModalVis model =
    if model.modalVisibility == Modal.shown then
        Modal.hidden

    else
        Modal.shown


view : Model -> Html Msg
view model =
    let
        navbarItems =
            Navbar.items
                [ Navbar.itemLink [ onClick (ToggleModal (toggleModalVis model)), href "#" ] [ text "Files" ]
                , Navbar.itemLink [ href "https://gitlab.com/BARICHELLO/cp-swf-archive" ] [ text "Archive" ]
                , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf" ] [ text "Source code" ]
                , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/LICENSE" ] [ text "License" ]
                , Navbar.itemLink [ href "https://github.com/aBARICHELLO/cp-swf/blob/master/README.md" ] [ text "About" ]
                ]

        navbar =
            Navbar.config NavbarMsg
                |> Navbar.withAnimation
                |> Navbar.darkCustom (Color.rgb255 0 51 102)
                |> Navbar.brand [ href "#" ] [ text "CP-SWF" ]
                |> navbarItems
                |> Navbar.view model.navbarState

        modalHeader =
            [ Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col
                        [ Col.xs6 ]
                        [ text "File" ]
                    , Grid.col
                        [ Col.xs6 ]
                        [ Button.button
                            [ Button.outlinePrimary
                            , Button.attrs [ id "reset-button", onClick ResetTree ]
                            ]
                            [ text "Reset" ]
                        , Button.button
                            [ Button.outlinePrimary
                            , Button.attrs [ id "hide-button", onClick (ToggleModal Modal.hidden) ]
                            ]
                            [ text "Hide" ]
                        ]
                    ]
                ]
            ]

        modalBody =
            div [] []

        modalFooter =
            Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col [] [ strong [] [ text "Current path:" ] ]
                    , Grid.col [] [ text (archiveToString model.archive) ]
                    ]
                , Grid.row []
                    [ Grid.col [] [ strong [] [ text "Loaded file:" ] ]
                    , Grid.col [] [ text model.loadedPath ]
                    ]
                ]

        dirModal =
            Grid.container []
                [ Modal.config None
                    |> Modal.small
                    |> Modal.h5 [] modalHeader
                    |> Modal.body [] [ modalBody ]
                    |> Modal.footer [] [ modalFooter ]
                    |> Modal.view model.modalVisibility
                ]
    in
    div []
        [ navbar
        , dirModal
        , div [ id "swf-content" ]
            [ embed [ id "swf", src model.loadedPath, width 2560, height 1440 ] []
            ]
        ]
