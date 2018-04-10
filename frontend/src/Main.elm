module Main exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode as JDec
import Navigation

import Admin exposing (..)
import Models exposing (..)
import Routing exposing (..)
import Update exposing (..)
import View.Utils exposing (..)



---- PROGRAM ----


main : Program Never Model Msg
main =
    Navigation.program RouteChanged
        { view = view
        , init = Models.init
        , update = Update.update
        , subscriptions = always Sub.none
        }



---- VIEW ----


stylesheet : Html msg
stylesheet =
    let
        tag = "link"
        attrs =
            [ attribute "rel"       "stylesheet"
            , attribute "property"  "stylesheet"
            , attribute "href"      "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
            ]
        children = []
    in 
        node tag attrs children


view : Model -> Html Msg
view model =
    let
        header = row
            [ div [ class "col" ] [ h1 [] [ text "Secret Santa" ] ]
            , div [ class "col-md-auto my-auto" ]
                [ input
                    [ class "form-control form-control-sm"
                    , type_ "number"
                    , on "input" (JDec.map MyId targetValueIntParse)
                    , defaultValue "0"
                    , Html.Attributes.min "0"
                    , model.me.id |> toString |> value
                    ]
                    []
                ]
            , div [ class "col-md-2 my-auto" ]
                [ select
                    [ on "change" (JDec.map TheirId targetValueIntParse)
                    , class "form-control form-control-sm"
                    , placeholder "Other profiles"
                    ]
                    (mapAssignedOptions model.assignedPicker)
                ]
            ]
        inner = row
            [ displayErr model
            , halfCol
                [ display MyProfile model.me
                , div [] (newWishlistInput model)
                , claimedItems MyProfile model.me
                ]
            , halfCol
                [ display TheirProfile model.them ]
            ]
    in
        case model.route of
            RouteMyProfile profileId ->
                div [ id "outer" ]
                    [ stylesheet
                    , container
                        [ header
                        , hr [] []
                        , displayErr model
                        , inner
                        ]
                    ]
            RouteAdmin ->
                div [ id "outer" ]
                    [ stylesheet
                    , container [ adminPanel model ]
                    ]
            RouteCreate ->
                div [ id "outer" ]
                    [ stylesheet
                    , container
                        [ header
                        , hr [] []
                        , displayErr model
                        , row [ loginForm model ]
                        ]
                    ]


display : Who -> Profile -> Html Msg
display who profile =
    let
        invalid = profile.id <= 0
    in
        case invalid of
            True -> nothing
            False -> div []
                [ h2 []
                    [ text (profile.name ++ " (")
                    , a [ href ("mailto:" ++ profile.email) ] [text profile.email ]
                    , text ")"
                    ]
                , h3 [] [ text "Wishlist" ]
                , div [] [ renderWishlistItems who profile.wishlist False ]
                ]


mapAssignedOptions : List ProfileLite -> List (Html Msg)
mapAssignedOptions entries =
    option [ value "0" ] [ text "Other Participants" ] :: List.map mapAssignedOption entries


mapAssignedOption : ProfileLite -> Html Msg
mapAssignedOption entry =
    option [ entry.id |> toString  |> value] [ text entry.name ]


claimedItems : Who -> Profile -> Html Msg
claimedItems who profile =
    case who of
        MyProfile ->
            div []
                [ h3 [] [ text "Claimed Items" ]
                , renderClaimedItems profile.claimedItems
                ]
        TheirProfile -> nothing


newWishlistInput : Model -> List (Html Msg)
newWishlistInput model =
    [ div
        [ class "input-group" ]
        [ input
            [ class "form-control form-control-sm"
            , name "wishlistItem"
            , onInput PossibleNewWishlistItem
            , value model.wishlistItemHolder
            ]
            []
        , div
            [ class "input-group-append" ]
            [ button
                [ class "btn btn-sm btn-outline-secondary"
                , type_ "button"
                , onClick SubmitNewWishlistItem
                , model.wishlistItemHolder |> String.isEmpty |> disabled
                ]
                [ text "Add Item" ]
            ]
        ]
    ]


renderClaimedItems : List WishlistItem -> Html Msg
renderClaimedItems items =
    case items of
        [] -> noItems "No claimed items."
        _ -> renderWishlistItems MyProfile items True


renderWishlistItems : Who -> List WishlistItem -> Bool -> Html Msg
renderWishlistItems who items claimedItems =
    case items of
        [] -> noItems "No wishlist items! Enter some below"
        _ -> div [] (List.map (renderWishlistItem who claimedItems) items)


renderWishlistItem : Who -> Bool -> WishlistItem -> Html Msg
renderWishlistItem who claimedItems item =
    div [ class "row" ]
        [ div [ class "col my-2" ] [ text (item.text ++ " (Owner: " ++ (toString item.owner) ++ ")") ]
        , div [ class "col-md-auto" ] [ claimLink who item.claimed claimedItems item.id ]
        ]


claimLink : Who -> Bool -> Bool -> Int -> Html Msg
claimLink who claimed claimedItems id =
    let
        cl = [ "btn", "btn-sm" ]
    in
    case (who, claimed, claimedItems) of
        (MyProfile, _, True) ->
            button
                [ onClick (UnclaimItem id)
                , "btn-outline-danger" :: cl |> classesEnable |> classList
                ]
                [ text "Unclaim" ]
        (TheirProfile, _, _) ->
            button
                [ onClick (ClaimItem id )
                , "btn-outline-primary" :: cl |> classesEnable |> classList
                , disabled claimed
                ]
                [ text "Claim" ]
        _ -> nothing



loginForm : Model -> Html Msg
loginForm model =
    div
        [ class "col" ]
        [ div [ class "form-row" ]
            [ div [ class "col" ]
                [ div [ class "form-group" ]
                    [ input
                        [ placeholder "Name"
                        , name "name"
                        , class "form-control"
                        , onInput NewUserName
                        , value model.newUser.name
                        ]
                        []
                    ]
                ]
            , div [ class "col" ]
                [ div [ class "form-group" ]
                    [ input
                        [ placeholder "Email"
                        , name "email"
                        , class "form-control"
                        , onInput NewUserEmail
                        , value model.newUser.email
                        ]
                        []
                    ]
                ]
            ]
        , div [ class "form-row" ]
            [ div [ class "col" ] [ button [ class "btn btn-primary form-control", onClick NewUser ] [ text "Create" ] ]
            ]
        ]


classesEnable : List String -> List (String, Bool)
classesEnable list = List.map classEnable list


classEnable : String -> (String, Bool)
classEnable cls = (cls, True)


noItems : String -> Html Msg
noItems message =
    div [ class "card text-center" ] [ div [ class "card-body" ] [ p [] [ text message ] ] ]