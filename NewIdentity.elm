module NewIdentity where

import Html exposing (..)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)

import Http
import Effects exposing (Effects, Never)
import Task

import Json.Decode as Json exposing (Decoder, (:=))

import StartApp


-- MODEL

type alias Address =
  { street: String
  , city: String
  , state: String
  }


type alias Model =
  { firstName: String
  , lastName: String
  , address: Address
  , email: String
  , photo: String
  }


-- UPDATE

type Action
  = NoOp
  | GetNewIdentity
  | NewIdentity (Maybe (List Model) )


update : Action -> Maybe Model -> (Maybe Model, Effects Action)
update action maybeModel =
  case action of
    GetNewIdentity ->
      ( maybeModel, fetchNewIdentity )

    NewIdentity maybeNewIdentity ->
      case maybeNewIdentity of
        Just model ->
          ( List.head model, Effects.none )

        Nothing ->
          ( maybeModel, Effects.none )

    NoOp ->
      ( maybeModel, Effects.none )


fetchNewIdentity : Effects Action
fetchNewIdentity =
  Http.get decodeIdentities "https://randomuser.me/api/"
    |> Task.toMaybe
    |> Task.map NewIdentity
    |> Effects.task


decodeIdentities : Json.Decoder Model
decodeIdentities =
  Json.object1 identity
    ("results" := Json.list modelDecoder)


modelDecoder : Json.Decoder Model
modelDecoder =
  Json.object5 Model
    (Json.at ["user", "name", "first"] Json.string)
    (Json.at ["user", "name", "last"] Json.string)
    (Json.at ["user", "location"] addressDecoder)
    (Json.at ["user", "email"] Json.string)
    (Json.at ["user", "picture", "medium"] Json.string)


addressDecoder : Json.Decoder Address
addressDecoder =
  Json.object3 Address
    ("street" := Json.string)
    ("city" := Json.string)
    ("state" := Json.string)


-- view

view : Signal.Address Action -> Maybe Model -> Html
view actionDispatcher maybeModel =
  div
    [ class "app-container"]
    [ div
      [ class "identity-card" ]
      (renderIdentityCard maybeModel)
    , button
        [ class "button", onClick actionDispatcher GetNewIdentity ]
        [ text "Get a New Identity" ]
    ]


renderIdentityCard : Maybe Model -> List Html
renderIdentityCard maybeModel =
  case maybeModel of
    Just model ->
      [ div
        [ class "identity-card--info" ]
        [ h4 [ class "info--name" ] [ text (model.firstName ++ " " ++ model.lastName) ]
        , p [] [ text model.address.street ]
        , p [] [ text model.address.city ]
        , p [] [ text model.address.state ]
        , p [] [ text model.email ]
        ]
      , div
        [ class "identity-card--picture" ]
        [ img [ src model.photo ] [] ]
      ]

    Nothing ->
      [ h1
          [ class "introduction" ]
          [ text "You are one click away from a new identity" ]
      ]


-- app
app =
  StartApp.start
    { init = ( Nothing, Effects.none )
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
