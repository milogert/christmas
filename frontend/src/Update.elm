module Update exposing (update)

import Debug exposing (log)
import Navigation exposing (..)

import Models exposing (..)
import Request exposing (..)
import Routing exposing (..)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewUserName name ->
            { model | newUser = name |> asNewUserNameIn model.newUser } ! []
        NewUserEmail email ->
            { model | newUser = email |> asNewUserEmailIn model.newUser } ! []
        NewUser ->
            { model | newUser = NewUserData "" "" } ! [ createNewUser model.newUser.name model.newUser.email ]

        MyId newId ->
            case (log "my id changed" newId) of
                0 -> model ! [ newUrl "#" ]
                _ -> model ! [ newUrl ("#" ++ toString newId) ]
        TheirId newId ->
            let
                zero = newId <= 0
                duplicateProfile = newId == model.me.id
            in
                case (zero, duplicateProfile) of
                    (True, _) -> { model | them = resetProfile } ! []
                    (_, True) -> { model | err = "Cannot select same id" } ! []
                    _ -> model ! [ getProfile TheirProfile newId ]

        UpdateTheirPicker (Ok mapGood) ->
            { model | assignedPicker = (log "assigned map" mapGood) } ! []
        UpdateTheirPicker (Err err) ->
            { model | assignedPicker = [], err = err |> toString } ! []

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
            { model | err = err |> toString } ! [ newUrl "#" ]
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

        RedirectRoute (Ok profile) ->
            model ! [ newUrl ("#" ++ toString profile.id) ]
        RedirectRoute (Err err) ->
            { model | err = toString err } ! []
        RouteChanged newLoc ->
            let
                route = log "RouteChanged" (parseLocation newLoc)
            in
                case route of
                    RouteMyProfile id ->
                        { model | route = route, them = resetProfile } ! [ getProfile MyProfile id ]
                    RouteAdmin ->
                        { model | route = route } ! []
                    _ ->
                        { model | route = RouteCreate, me = resetProfile, them = resetProfile } ! [ ]

        ClearError ->
            { model | err = "" } ! []

        MakePairs ->
            model ! [ makePairsRequest ]
        PairsMade (Ok _) ->
            model ! [ newUrl "#" ]
        PairsMade (Err err) ->
            { model | err = err |> toString } ! [ newUrl "#admin" ]


-- Helpers.


asNewUserIn : Model -> NewUserData -> Model
asNewUserIn = flip setNewUserData


asNewUserNameIn : NewUserData -> String -> NewUserData
asNewUserNameIn = flip setNewUserName


asNewUserEmailIn : NewUserData -> String -> NewUserData
asNewUserEmailIn = flip setNewUserEmail


-- Trash helpers.


setNewUserData : NewUserData -> Model -> Model
setNewUserData data model = { model | newUser = data }


setNewUserName : String -> NewUserData -> NewUserData
setNewUserName name data = { data | name = name }


setNewUserEmail : String -> NewUserData -> NewUserData
setNewUserEmail email data = { data | email = email }