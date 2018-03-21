module Main exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode as JDec

import Models exposing (..)
import Update exposing (..)



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
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
        inner = div
            [ class "container" ]
            [ row
                [ fullCol [ h1 [] [ text "Secret Santa" ] ]
                , fullCol [ p [ id "err" ] [ text model.err ] ]
                , halfCol
                    [ p [] [ text "Me:" ]
                    , input
                        [ id "my-id"
                        , type_ "number"
                        , on "input" (JDec.map MyId targetValueIntParse)
                        , defaultValue "0"
                        , Html.Attributes.min "0"
                        , class "form-control form-control-sm"
                        ]
                        []
                    , div [] (createOrDisplay MyProfile model.me)
                    ]
                , halfCol
                    [ p [] [ text "Profile:" ]
                    , select
                        [ on "change" (JDec.map TheirId targetValueIntParse)
                        , class "form-control form-control-sm"
                        , placeholder "Other profiles"
                        ]
                        (mapAssignedOptions model.assignedPicker)
                    {--
                    , input
                        [ id "their-id"
                        , type_ "number"
                        , on "input" (JDec.map TheirId targetValueIntParse)
                        , defaultValue "0"
                        , Html.Attributes.min "0"
                        ]
                        []
                    --}
                    , display TheirProfile model.them
                    ]
                ]
            ]
    in
        div [ id "outer" ] [ stylesheet, inner ]


row : List (Html Msg) -> Html Msg
row elements =
    div [ class "row" ] elements


fullCol : List (Html Msg) -> Html Msg
fullCol elements =
    div [ class "col-md-12" ] elements


halfCol : List (Html Msg) -> Html Msg
halfCol elements =
    div [ class "col-md-6" ] elements


createOrDisplay : Who -> Profile -> List (Html Msg)
createOrDisplay who profile =
    let
        validId = profile.id > 0
    in
        case validId of
            False -> [ loginForm ]
            True ->
                [ display who profile
                , div [] newWishlistInput
                , claimedItems who profile
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
    option [ value "0" ] [] :: List.map mapAssignedOption entries


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


newWishlistInput : List (Html Msg)
newWishlistInput =
    [ div
        [ class "input-group" ]
        [ input
            [ class "form-control form-control-sm"
            , name "wishlistItem"
            , onInput PossibleNewWishlistItem
            ] []
        , div
            [ class "input-group-append" ]
            [ button
                [ class "btn btn-sm btn-outline-secondary"
                , type_ "button"
                , onClick SubmitNewWishlistItem
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



loginForm : Html Msg
loginForm =
    Html.form
        [ action "/profile/add" ]
        [ input [ placeholder "Name", name "name", class "form-control" ] []
        , input [ placeholder "Email", name "email", class "form-control" ] []
        , button [ type_ "submit", class "form-control" ] [ text "Create" ]
        ]


nothing : Html Msg
nothing = text ""


classesEnable : List String -> List (String, Bool)
classesEnable list = List.map classEnable list


classEnable : String -> (String, Bool)
classEnable cls = (cls, True)


noItems : String -> Html Msg
noItems message =
    div [ class "card text-center" ] [ div [ class "card-body" ] [ p [] [ text message ] ] ]