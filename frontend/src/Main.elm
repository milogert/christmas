module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
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


type alias Profile =
    { id : Int
    , name : String
    , email : String
    , wishlist : List WishlistItem
    , error : String
    }


type alias Model =
    { me : Profile
    , them : Profile
    }


init : ( Model, Cmd Msg )
init =
    (
        { me =
            { id = 0
            , name = ""
            , email = ""
            , wishlist = []
            , error = ""
            }
        , them =
            { id = 0
            , name = ""
            , email = ""
            , wishlist = []
            , error = ""
            }
        }
    , Cmd.none
    )


---- UPDATE ----


type Msg
    = NewUser
    | MyId Int
    | TheirId Int
    | GetProfile (Result Http.Error Profile)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MyId newId ->
            case newId of
                0 -> (model, Cmd.none)
                _ ->
                    let
                        nme = model.me
                        nthem = model.them
                    in
                        ( { model | me = { nme | id = newId }, them = nthem }
                        , getProfile model.me newId
                        )
        TheirId newId ->
            case newId of
                0 -> (model, Cmd.none)
                _ ->
                    let
                        nme = model.me
                        nthem = model.them
                    in
                        ( { model | me = nme, them = { nthem | id = newId } }
                        , getProfile model.them newId
                        )
        NewUser -> (model, Cmd.none)
        GetProfile (Ok foundPerson) ->
            let
                modelMe = model.me
                modelThem = model.them
            in
                log "GetProfile Ok"
                (
                    { model
                    | me =
                        { modelMe
                        | id = foundPerson.id
                        , name = foundPerson.name
                        , email = foundPerson.email
                        , wishlist = foundPerson.wishlist
                        , error = ""
                        }
                    }
                , Cmd.none
                )
        GetProfile (Err err) ->
            let
                modelMe = model.me
                modelThem = model.them
            in
                log "GetProfile Error"
                (
                    { model
                    | me =
                        { modelMe
                        | id = -1
                        , name = "None"
                        , email = "none@localhost"
                        , wishlist = []
                        , error = toString err
                        }
                    }
                , Cmd.none
                )


getProfile : Profile -> Int -> Cmd Msg
getProfile profile id =
    let
        url = "http://192.168.0.50:8080/person/profile/" ++ (toString id)
        request = Http.get (log "pulling profile" url) decodeProfile
    in
        Http.send GetProfile (log "GetProfile" request)


decodeProfile : Json.Decode.Decoder Profile
decodeProfile =
    Json.Decode.Pipeline.decode Profile
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


stylesheet =
    let
        tag = "link"
        attrs =
            [ attribute "rel"       "stylesheet"
            , attribute "property"  "stylesheet"
            , attribute "href"      "//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
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
                , halfCol
                    [ p [] [ text "Me:" ]
                    , input
                        [ id "my-id"
                        , type_ "number"
                        , on "input" (Json.Decode.map MyId targetValueIntParse)
                        , defaultValue "0"
                        , Html.Attributes.min "0"
                        ]
                        []
                    , p [ id "err" ] [ text model.me.error ]
                    , createOrDisplay model.me
                    ]
                , halfCol
                    [ p [] [ text "Profile:" ]
                    , input
                        [ id "their-id"
                        , type_ "number"
                        , on "input" (Json.Decode.map TheirId targetValueIntParse)
                        , defaultValue "0"
                        , Html.Attributes.min "0"
                        ]
                        []
                    , p [ id "err" ] [ text model.them.error ]
                    , display model.them
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


createOrDisplay : Profile -> Html Msg
createOrDisplay profile =
    case profile.id of
        0 -> loginForm
        _ -> display profile


display : Profile -> Html Msg
display profile =
    div []
        [ h2 []
            [ text ((log "name" profile.name) ++ " (")
            , a [ href ("mailto:" ++ (log "email" profile.email)) ] [text profile.email ]
            , text ")"
            ]
        , div [] [ renderWishlistItems profile.wishlist ]
        ]


renderWishlistItems : List WishlistItem -> Html Msg
renderWishlistItems items =
    ul [] (List.map renderWishlistItem items)


renderWishlistItem : WishlistItem -> Html Msg
renderWishlistItem item =
    li []
        [ text <| toString item.id
        , text ": "
        , text item.text
        , text ", claimed: "
        , text <| toString item.claimed
        ]


loginForm : Html Msg
loginForm =
    Html.form
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
