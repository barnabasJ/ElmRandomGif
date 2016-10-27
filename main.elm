module Main exposing (..)

import RandomGif exposing (init, update, view)
import Html.App as App


main =
    App.program
        { init = init "funny cats"
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions model =
    Sub.none
