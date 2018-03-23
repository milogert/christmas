module Models exposing (..)

import Http
import Navigation exposing (..)
import Task exposing (Task)

import Routing exposing (..)



type Msg
    = NewUserName String
    | NewUserEmail String
    | NewUser
    | MyId Int
    | UpdateTheirPicker (Result Http.Error (List ProfileLite))
    | TheirId Int
    | GetMyProfile (Result Http.Error Profile)
    | GetTheirProfile (Result Http.Error Profile)
    | PossibleNewWishlistItem String
    | SubmitNewWishlistItem
    | ClaimItem Int
    | UnclaimItem Int
    | RedirectRoute (Result Http.Error Profile)
    | RouteChanged Location
    | ClearError


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route = location |> parseLocation
    in
        { me = resetProfile
        , them = resetProfile
        , newUser = NewUserData "" ""
        , wishlistItemHolder = ""
        , assignedPicker = []
        , route = route
        , err = ""
        } ! [ Task.succeed location |> Task.perform RouteChanged ]


type alias Model =
    { me : Profile
    , them : Profile
    , newUser : NewUserData
    , wishlistItemHolder : String
    , assignedPicker : List ProfileLite
    , route : Route
    , err : String
    }


type alias ProfileLite =
    { id : Int
    , name : String
    }


type alias Profile =
    { id : Int
    , name : String
    , email : String
    , wishlist : List WishlistItem
    , claimedItems : List WishlistItem
    , receivers : List ProfileLite
    }


type alias NewUserData =
    { name : String
    , email : String
    }


type alias WishlistItem =
    { id : Int
    , owner : Int
    , text : String
    , claimed : Bool
    , claimedBy : Int
    }


type Who = MyProfile | TheirProfile


-- UTILITIES.


resetProfile : Profile
resetProfile = resetProfileWithErr ""


resetProfileWithErr : String -> Profile
resetProfileWithErr err =
    { id = 0
    , name = ""
    , email = ""
    , wishlist = []
    , claimedItems = []
    , receivers = []
    }
