module RandomGif exposing (init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Task
import Http
import Json.Decode as Json


type alias Gif =
    { identifier : Int
    , topic : String
    , gifUrl : String
    }


type alias Model =
    { gifs : List Gif
    , topic : String
    , nextIdentifier : Int
    }


init : String -> ( Model, Cmd Msg )
init topic =
    let
        gif =
            Gif 0 topic "assets/waiting.gif"
    in
        ( Model [ gif ] "" 1
        , (getRandomGif gif)
        )


type Msg
    = RequestMore Gif
    | FetchSucceed Int String
    | FetchFail Gif
    | UpdateField String
    | AddGif


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestMore gif ->
            let
                updateGif thisGif =
                    if thisGif.identifier == gif.identifier then
                        { thisGif | gifUrl = "assets/waiting.gif" }
                    else
                        thisGif
            in
                ( { model | gifs = List.map updateGif model.gifs }
                , getRandomGif gif
                )

        FetchSucceed identifier maybeUrl ->
            let
                updateGif thisGif =
                    if thisGif.identifier == identifier then
                        { thisGif | gifUrl = maybeUrl }
                    else
                        thisGif
            in
                { model
                    | gifs = List.map updateGif model.gifs
                }
                    ! []

        FetchFail gif ->
            ( model
            , getRandomGif gif
            )

        UpdateField str ->
            { model
                | topic = str
            }
                ! []

        AddGif ->
            let
                getNewRandomGif =
                    getRandomGif
                        { identifier = model.nextIdentifier
                        , topic = model.topic
                        , gifUrl = "assets/waiting.gif"
                        }
            in
                ( { model
                    | gifs =
                        { identifier = model.nextIdentifier
                        , topic = model.topic
                        , gifUrl = "assets/waiting.gif"
                        }
                            :: model.gifs
                    , topic = ""
                    , nextIdentifier = model.nextIdentifier + 1
                  }
                , getNewRandomGif
                )


(=>) =
    (,)


view : Model -> Html Msg
view model =
    div []
        [ Html.form
            [ style [ "width" => "200px" ]
            , onSubmit AddGif
            ]
            [ input
                [ type' "text"
                , placeholder "New Topic"
                , value model.topic
                , autofocus True
                , onInput UpdateField
                ]
                []
            , button [ type' "submit" ] [ text "More Please" ]
            ]
        , div [ style [ "display" => "flex" ] ]
            (List.map (gifView) model.gifs)
        ]


gifView : Gif -> Html Msg
gifView gif =
    div [ style [ "width" => "200px" ] ]
        [ h2 [ headerStyle ] [ text gif.topic ]
        , div [ imgStyle gif.gifUrl ] []
        , button [ onClick (RequestMore gif) ] [ text "More Please" ]
        ]


headerStyle : Attribute Msg
headerStyle =
    style
        [ "width" => "200px"
        , "text-align" => "center"
        ]


imgStyle : String -> Attribute Msg
imgStyle url =
    style
        [ "display" => "inline-block"
        , "width" => "200px"
        , "height" => "200px"
        , "background-position" => "center center"
        , "background-size" => "cover"
        , "background-image" => ("url('" ++ url ++ "')")
        ]


getRandomGif : Gif -> Cmd Msg
getRandomGif gif =
    let
        url =
            randomUrl gif.topic
    in
        Task.perform
            (\_ -> FetchFail gif)
            (FetchSucceed gif.identifier)
            (Http.get decodeGifUrl url)


randomUrl : String -> String
randomUrl topic =
    Http.url "http://api.giphy.com/v1/gifs/random"
        [ "api_key" => "dc6zaTOxFJmzC"
        , "tag" => topic
        ]


decodeGifUrl : Json.Decoder String
decodeGifUrl =
    Json.at [ "data", "image_url" ] Json.string
