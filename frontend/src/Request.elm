module Request exposing (..)

import Debug exposing (log)
import Http exposing (Error)
import Json.Decode as JDec
import Json.Decode.Pipeline as JPipe
import Navigation exposing (..)

import Models exposing (..)
import Routing exposing (..)



createNewUser : String -> String -> Cmd Msg
createNewUser name email =
    let
        url = "http://localhost:8080/person/add?name=" ++ name ++ "&email=" ++ email
        request = Http.get (log "adding profile" url) decodeProfile
    in
        Http.send RedirectRoute request


getProfile : Who -> Int -> Cmd Msg
getProfile who id =
    let
        url = "http://localhost:8080/person/profile/" ++ (toString id) ++ "?me=" ++ (who |> whoToMe |> toString)
        request = Http.get (log "pulling profile" url) decodeProfile
    in
        case who of
            MyProfile -> Http.send GetMyProfile request
            TheirProfile -> Http.send GetTheirProfile request


getProfileFromRoute : Who -> Route -> Cmd Msg
getProfileFromRoute who route =
    case route of
        RouteCreate ->
            newUrl "#"
        RouteMyProfile id ->
            getProfile MyProfile id
        RouteAdmin -> newUrl "#admin"


getAssigned : Int -> Cmd Msg
getAssigned id =
    let
        url = "http://localhost:8080/person/assigned?santa=" ++ (id |> toString)
        request = Http.get (log "pulling assigned" url) (JDec.list decodeProfileLite)
    in
        Http.send UpdateTheirPicker request


submitWishlistItem : Int -> String -> Cmd Msg
submitWishlistItem id text =
    let
        url = "http://localhost:8080/wishlist/add?id=" ++ (toString id) ++ "&text=" ++ text
        request = Http.get url decodeProfile
    in
        Http.send GetMyProfile (log "GetProfile" request)


claimItem : Int -> Int -> Cmd Msg
claimItem profileId itemId =
    let
        url = "http://localhost:8080/wishlist/claim?santaId=" ++ (toString profileId) ++ "&wishlistItem=" ++ (toString itemId)
        request = Http.get url decodeProfile
    in
        Http.send GetMyProfile (log "claimItem" request)


unclaimItem : Int -> Int -> Cmd Msg
unclaimItem profileId itemId =
    let
        url = "http://localhost:8080/wishlist/unclaim?santaId=" ++ (toString profileId) ++ "&wishlistItem=" ++ (toString itemId)
        request = Http.get url decodeProfile
    in
        Http.send GetMyProfile (log "unclaimItem" request)


makePairsRequest : Cmd Msg
makePairsRequest =
    let
        url = "http://localhost:8080/pair"
        request = Http.getString url
    in
        Http.send PairsMade (log "unclaimItem" request)


-- UTILITIES.


whoToMe : Who -> Bool
whoToMe who =
    case who of
        MyProfile -> True
        TheirProfile -> False


-- PROFILE.


decodeProfile : JDec.Decoder Profile
decodeProfile =
    JPipe.decode Profile
        |> JPipe.required "id" (JDec.int)
        |> JPipe.required "name" (JDec.string)
        |> JPipe.required "email" (JDec.string)
        |> JPipe.required "wishlist" decodeWishlistItems
        |> JPipe.required "claimedItems" decodeWishlistItems
        |> JPipe.required "receivers" (JDec.list decodeProfileLite)


-- WISHLIST.


decodeWishlistItems : JDec.Decoder (List WishlistItem)
decodeWishlistItems =
    JDec.list decodeWishlistItem


decodeWishlistItem : JDec.Decoder WishlistItem
decodeWishlistItem =
    JPipe.decode WishlistItem
        |> JPipe.required "id" (JDec.int)
        |> JPipe.required "owner" (JDec.int)
        |> JPipe.required "text" (JDec.string)
        |> JPipe.required "claimed" (JDec.bool)
        |> JPipe.optional "claimedBy" (JDec.int) -1


decodeProfileLite : JDec.Decoder ProfileLite
decodeProfileLite =
    JPipe.decode ProfileLite
        |> JPipe.required "id" (JDec.int)
        |> JPipe.required "name" (JDec.string)

