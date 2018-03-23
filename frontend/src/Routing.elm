module Routing exposing (..)

import Debug exposing (log)
import Navigation exposing (Location)
import UrlParser exposing (..)



type Route
    = RouteCreate
    | RouteMyProfile Int


route : Parser (Route -> a) a
route =
    oneOf
        [ map RouteMyProfile (int) ]


parseLocation : Location -> Route
parseLocation location =
    case log "parsed loc" (parseHash route (log "location" location)) of
        Just r ->
            r

        Nothing ->
            RouteCreate
