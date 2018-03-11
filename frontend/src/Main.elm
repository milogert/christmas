module Main exposing (..)

import Html exposing (Html, text, div, h1, h2, img, form, input, button, a, p)
import Html.Attributes exposing (src, action, placeholder, name, type_, id, defaultValue, min, href)
import Html.Events exposing (on)
import Html.Events.Extra exposing (targetValueIntParse)
import Json.Decode
import Json.Decode.Pipeline
import Debug exposing (..)
import Http exposing (Error)


---- MODEL ----


type alias WishlistItem =
    { id : Int
    , text : String
    , claimed : Bool
    , claimedBy : Int
    }


type alias Person =
    { id : Int
    , name : String
    , email : String
    , wishlist : List WishlistItem
    , error : String
    }


init : ( Person, Cmd Msg )
init =
    (
        { id = 0
        , name = ""
        , email = ""
        , wishlist = []
        , error = ""
        }
    , Cmd.none
    )


---- UPDATE ----


type Msg
    = NewUser
    | FoundId Int
    | GetProfile (Result Http.Error Person)


update : Msg -> Person -> (Person, Cmd Msg)
update msg model =
    case msg of
        FoundId newId ->
            case newId of
                0 -> (model, Cmd.none)
                _ ->
                    ( { model | id = (log "id" newId) }
                    , getProfile model newId
                    )
        NewUser -> (model, Cmd.none)
        GetProfile (Ok foundPerson) ->
            log "GetProfile Ok" (
                { model
                | id = foundPerson.id
                , name = foundPerson.name
                , email = foundPerson.email
                , wishlist = foundPerson.wishlist
                , error = ""
                }
            , Cmd.none
            )
        GetProfile (Err err) ->
            log "GetProfile Error" (
                { model
                | id = -1
                , name = "None"
                , email = "none@localhost"
                , wishlist = []
                , error = toString err
                }
            , Cmd.none
            )


getProfile : Person -> Int -> Cmd Msg
getProfile model id =
    let
        url = "http://localhost:8080/person/profile/" ++ (toString id)
        request = Http.get (log "pulling profile" url) decodeProfile
    in
        Http.send GetProfile (log "GetProfile" request)


decodeProfile : Json.Decode.Decoder Person
decodeProfile =
    Json.Decode.Pipeline.decode Person
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "email" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "wishlist" decodeWishlistItems
        |> Json.Decode.Pipeline.optional "error" (Json.Decode.string) ""


decodeWishlistItems : Json.Decode.Decoder (List WishlistItem)
decodeWishlistItems =
    Json.Decode.list decodeWishlistItem


decodeWishlistItem : Json.Decode.Decoder WishlistItem
decodeWishlistItem =
    Json.Decode.Pipeline.decode WishlistItem
        |> Json.Decode.Pipeline.required "id" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "text" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "claimed" (Json.Decode.bool)
        |> Json.Decode.Pipeline.optional "claimedBy" (Json.Decode.int) -1


---- VIEW ----


view : Person -> Html Msg
view model =
    div []
        [ h1 [] [ text "Secret Santa" ]
        , input
            [ id "id"
            , type_ "number"
            , on "input" (Json.Decode.map FoundId targetValueIntParse)
            , defaultValue "0"
            , Html.Attributes.min "0"
            ]
            []
        , p [ id "err" ] [ text model.error ]
        , createOrDisplay model
        ]


createOrDisplay : Person -> Html Msg
createOrDisplay model =
    case model.id of
        0 -> loginForm
        _ -> display model


display : Person -> Html Msg
display model =
    div []
        [ h2 []
            [ text ((log "name" model.name) ++ " (")
            , a [ href ("mailto:" ++ (log "email" model.email)) ] [text model.email ]
            , text ")"
            ]
        , div [] (renderWishlistItems model.wishlist)
        ]


renderWishlistItems : List WishlistItem -> List (Html Msg)
renderWishlistItems items =
    List.map renderWishlistItem items


renderWishlistItem : WishlistItem -> Html Msg
renderWishlistItem item =
    p []
        [ text <| toString item.id
        , text ": "
        , text item.text
        , text ", claimed: "
        , text <| toString item.claimed
        ]


loginForm : Html Msg
loginForm =
    form
        [ action "/profile/add" ]
        [ input [ placeholder "Name", name "name" ] []
        , input [ placeholder "Email", name "email" ] []
        , button [ type_ "submit" ] [ text "Create" ]
        ]


---- PROGRAM ----


main : Program Never Person Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
