module Admin exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)

import Models exposing (..)
import View.Utils exposing (..)


adminPanel : Model -> Html Msg
adminPanel model =
    div
        []
        [ row [ fullCol [ h1 [] [ text "Admin Panel" ] ] ]
        , hr [] []
        , displayErr model
        , row [ fullCol [ makePairsButton ] ]
        ]


makePairsButton : Html Msg
makePairsButton =
    button
        [ onClick MakePairs
        , class "btn btn-primary"
        ]
        [ text "Pair" ]