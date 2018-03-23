module Update exposing (update)

import Debug exposing (log)
import Navigation exposing (..)

import Models exposing (..)
import Request exposing (..)
import Routing exposing (..)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MyId newId ->
            case newId of
                0 -> { model | me = resetProfile } ! []
                _ -> model !
                    [ getProfile MyProfile newId ]
        UpdateTheirPicker (Ok mapGood) ->
            { model | assignedPicker = (log "assigned map" (List.append model.me.receivers mapGood)) } ! []
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
                np = log "GetMyProfile" foundPerson
            in
                { model
                | me =
                    { modelMe
                    | id = np.id
                    , name = np.name
                    , email = np.email
                    , wishlist = np.wishlist
                    , claimedItems = np.claimedItems
                    , receivers = np.receivers
                    }
                }
                ! [ getAssigned np.id ]
        GetMyProfile (Err err) ->
            { model | err = err |> toString } ! []
        GetTheirProfile (Ok foundPerson) ->
            let
                modelThem = model.them
                np = log "GetTheirProfile" foundPerson
            in
                { model
                | them =
                    { modelThem
                    | id = np.id
                    , name = np.name
                    , email = np.email
                    , wishlist = np.wishlist
                    , receivers = np.receivers
                    }
                } ! []
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

        RouteChanged newLoc ->
            let
                route = parseLocation newLoc
            in
                case route of
                    RouteMyProfile id ->
                        model ! [ getProfile MyProfile id ]
                    _ ->
                        { model | me = resetProfile, them = resetProfile } ! []

        ClearError ->
            { model | err = "" } ! []