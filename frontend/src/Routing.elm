module Routing exposing (..)

import Debug exposing (log)
import Navigation exposing (Location)
import UrlParser exposing (..)



type Route
    = RouteCreate
    | RouteMyProfile Int
    | RouteAdmin


route : Parser (Route -> a) a
route =
    oneOf
        [ map RouteMyProfile (int)
        , map RouteAdmin (s "admin")
        ]


parseLocation : Location -> Route
parseLocation location =
    case log "parsed loc" (parseHash route (log "location" location)) of
        Just r ->
            r

        Nothing ->
            RouteCreate
