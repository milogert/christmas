module View.Utils exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Models exposing (..)


container : List (Html Msg) -> Html Msg
container elements =
    div [ class "container" ] elements


row : List (Html Msg) -> Html Msg
row elements =
    div [ class "row" ] elements


fullCol : List (Html Msg) -> Html Msg
fullCol elements =
    div [ class "col-md-12" ] elements


halfCol : List (Html Msg) -> Html Msg
halfCol elements =
    div [ class "col-md-6" ] elements


displayErr : Model -> Html Msg
displayErr model =
    case model.err of
        "" -> nothing
        _ ->
            fullCol
                [ row
                    [ div [ class "alert alert-danger col" ] [ text model.err ]
                    , div [ class "col-md-auto" ] [ button [ class "btn btn-outline-danger", onClick ClearError ] [ text "ClearError" ] ]
                    ]
                ]


nothing : Html Msg
nothing = text ""