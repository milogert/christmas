module Main exposing (..)

import Html exposing (Html, text, div, h1, img, form, input, button)
import Html.Attributes exposing (src, action, placeholder, name, type_, id, defaultValue)
import Html.Events exposing (on)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode as Json
import Debug exposing (log)



---- MODEL ----


type alias Model =
    { id : Int
    , name : String
    , email : String
    , error : String
    }

init : ( Model, Cmd Msg )
init =
    (
        { id = 0
        , name = ""
        , email = ""
        , error = ""
        }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NewUser
    | FoundId Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FoundId newId ->
            ( { model | id = (log "id" newId) }
            , Cmd.none
            )
        NewUser ->
            (model, Cmd.none)



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        , input
            [ id "id"
            , type_ "number"
            , on "input" (Json.map FoundId targetValueIntParse)
            , defaultValue "0"
            ]
            []
        , createOrDisplay model
        ]


createOrDisplay : Model -> Html Msg
createOrDisplay model =
    case model.id of
        0 -> loginForm
        _ -> display model.id


display : Int -> Html Msg
display id =
     div [] [ text (toString id) ]


loginForm : Html Msg
loginForm =
    form
        [ action "/profile/add" ]
        [ input [ placeholder "Name", name "name" ] []
        , input [ placeholder "Email", name "email" ] []
        , button [ type_ "submit" ] [ text "Create" ]
        ]


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
