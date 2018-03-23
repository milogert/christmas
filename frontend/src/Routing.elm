module Routing exposing (..)

import Debug exposing (log)
import Navigation exposing (Location)
import Models exposing (..)
import UrlParser exposing (..)



route : Parser (Route -> a) a
route =
    oneOf
        [ map RouteCreate top
        , map RouteMyProfile (int)
        ]


parseLocation : Location -> Route
parseLocation location =
    case log "parsed loc" (parseHash route (log "location" location)) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
