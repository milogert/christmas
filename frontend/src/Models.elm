module Models exposing (..)

import Http



type Msg
    = NewUser
    | MyId Int
    | UpdateTheirPicker (Result Http.Error (List ProfileLite))
    | TheirId Int
    | GetMyProfile (Result Http.Error Profile)
    | GetTheirProfile (Result Http.Error Profile)
    | PossibleNewWishlistItem String
    | SubmitNewWishlistItem
    | ClaimItem Int
    | UnclaimItem Int


init : ( Model, Cmd Msg )
init =
    (
        { me = resetProfile
        , them = resetProfile
        , wishlistItemHolder = ""
        , assignedPicker = []
        , err = ""
        }
    , Cmd.none
    )


type alias Model =
    { me : Profile
    , them : Profile
    , wishlistItemHolder : String
    , assignedPicker : List ProfileLite
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


type alias WishlistItem =
    { id : Int
    , owner : Int
    , text : String
    , claimed : Bool
    , claimedBy : Int
    }


type Who = MyProfile | TheirProfile


type Route
    = Create
    | DisplayProfile Int
    | NotFoundRoute


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
