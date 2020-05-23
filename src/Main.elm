module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, div, embed, text)
import Html.Attributes exposing (height, id, src, width)


type alias Model =
    { none : String
    }


type Msg
    = None


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
    ( { none = "a" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div [ id "header" ] [ text "https://github.com/aBARICHELLO/cp-swf" ]
        , div [ id "swf-content" ]
            [ embed [ src "cp-swf-data/2017/rooms/town.swf", width 2560, height 1440 ] []
            ]
        ]
