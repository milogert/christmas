module Update exposing (update)

import Debug exposing (log)

import Models exposing (..)
import Request exposing (..)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MyId newId ->
            case newId of
                0 -> { model | me = resetProfile } ! []
                _ -> model !
                    [ getProfile MyProfile newId
                    , getAssigned newId
                    ]
        UpdateTheirPicker (Ok mapGood) ->
            { model | assignedPicker = (log "assigned map" (List.append model.me.receivers mapGood)), them = resetProfile } ! []
        UpdateTheirPicker (Err err) ->
            { model | assignedPicker = [], err = err |> toString } ! []
        TheirId newId ->
            let
                zero = newId <= 0
                duplicateProfile = newId == model.me.id
            in
                case (zero, duplicateProfile) of
                    (True, _) -> { model | them = resetProfile } ! []
                    (_, True) -> { model | err = "Cannot select same id" } ! []
                    _ -> model ! [ getProfile TheirProfile newId ]
        NewUser -> (model, Cmd.none)
        GetMyProfile (Ok foundPerson) ->
            let
                modelMe = model.me
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
                        , claimedItems = foundPerson.claimedItems
                        , receivers = foundPerson.receivers
                        }
                    }
                , Cmd.none
                )
        GetMyProfile (Err err) ->
            { model | err = err |> toString } ! []
        GetTheirProfile (Ok foundPerson) ->
            let
                modelThem = model.them
            in
                log "GetProfile Ok"
                (
                    { model
                    | them =
                        { modelThem
                        | id = foundPerson.id
                        , name = foundPerson.name
                        , email = foundPerson.email
                        , wishlist = foundPerson.wishlist
                        , receivers = foundPerson.receivers
                        }
                    }
                , Cmd.none
                )
        GetTheirProfile (Err err) ->
            { model | err = err |> toString } ! []

        PossibleNewWishlistItem item ->
            { model | wishlistItemHolder = item } ! []
        SubmitNewWishlistItem ->
            { model | wishlistItemHolder = "" } !
            [ submitWishlistItem model.me.id model.wishlistItemHolder ]
        ClaimItem id ->
            let
                theirIdInvalid = model.them.id <= 0
            in
                case theirIdInvalid of
                    True ->
                        model !
                        [ claimItem model.me.id id ]
                    False ->
                        model !
                        [ claimItem model.me.id id
                        , getProfile TheirProfile model.them.id
                        ]
        UnclaimItem id ->
            let
                theirIdInvalid = model.them.id <= 0
            in
                case theirIdInvalid of
                    True ->
                        model !
                        [ unclaimItem model.me.id id ]
                    False ->
                        model !
                        [ unclaimItem model.me.id id
                        , getProfile TheirProfile model.them.id
                        ]