module Main exposing (Msg(..), main, update, view)

import Archive exposing (Archive, archiveDecoder, defaultSelectedPath, emptyArchive)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser
import Color
import Html exposing (Html, button, div, embed, text)
import Html.Attributes exposing (height, href, id, src, width)
import Html.Events exposing (onClick)
import Json.Decode exposing (decodeString)
import Requests exposing (ArchiveJSON(..), fetchArchive)
import Utils exposing (errorToString, listToString)


type alias Model =
    { archive : Archive
    , archiveStr : String
    , selectedPath : List String
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
      , archiveStr = ""
      , selectedPath = defaultSelectedPath
      , loadedPath = "./cp-swf-archive/2017/parties/waddle-on/town.swf"
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
                    in
                    ( { model | archive = archive }, Cmd.none )

        ResetTree ->
            ( { model | selectedPath = defaultSelectedPath }, Cmd.none )

        TraverseTree _ ->
            ( model
            , Cmd.none
            )

        LoadSWF ->
            ( { model | loadedPath = makeSWFPath model }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ToggleModal vis ->
            ( { model | modalVisibility = vis }, Cmd.none )


makeSWFPath : Model -> String
makeSWFPath model =
    let
        list =
            List.intersperse "/" model.selectedPath
    in
    listToString list


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
            [ text "Files"
            , Button.button
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

        modalBody =
            -- zipperToHtml model.zipper
            div [] []

        modalFooter =
            let
                list =
                    List.intersperse "/" model.selectedPath
            in
            [ text (listToString list) ]

        dirModal =
            Grid.container []
                [ Modal.config None
                    |> Modal.small
                    |> Modal.h5 [] modalHeader
                    |> Modal.body [] [ modalBody ]
                    |> Modal.footer [] modalFooter
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
