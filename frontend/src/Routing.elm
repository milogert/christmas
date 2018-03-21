module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (..)
import UrlParser exposing (..)



matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Create top
        , map DisplayProfile (s "id" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute