module Main exposing (..)

import RandomGifGenerator exposing (init, update, view)
import Html.App as App


main =
    App.program
        { init = init ( "left", "funny cats" ) ( "right", "funny dogs" )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions model =
    Sub.none
