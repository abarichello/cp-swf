module Main exposing (Msg(..), main, update, view)

import Archive exposing (defaultSelectedPath, maxTreeDepth, pathHeader, treeExample)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser
import Color
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
    , modalVisibility : Modal.Visibility
    }


type Msg
    = None
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
    in
    ( { tree = treeExample
      , zipper = fromTree treeExample
      , selectedPath = defaultSelectedPath
      , loadedPath = "./cp-swf-archive/2017/parties/waddle-on/town.swf"
      , navbarState = navbarState
      , modalVisibility = Modal.shown
      }
    , navbarCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

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
                                { model | selectedPath = pathHeader :: selectedPath }
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

        ToggleModal vis ->
            ( { model | modalVisibility = vis }, Cmd.none )


makeSWFPath : Model -> String
makeSWFPath model =
    let
        list =
            List.intersperse "/" model.selectedPath
    in
    listToString list


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
            zipperToHtml model.zipper

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
                    |> Modal.body [] modalBody
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
