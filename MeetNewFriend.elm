module MeetNewFriend where

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
  = GetNewFriend
  | NewFriend (Maybe (List Model) )


update : Action -> Maybe Model -> (Maybe Model, Effects Action)
update action maybeModel =
  case action of
    GetNewFriend ->
      ( maybeModel, fetchNewFriend )

    NewFriend friends ->
      getNewModelState friends maybeModel


getNewModelState : Maybe (List Model) -> Maybe Model -> (Maybe Model, Effects Action)
getNewModelState models defaultModel =
  case models of
    Just model ->
      ( List.head model, Effects.none )

    Nothing ->
      ( defaultModel, Effects.none )


fetchNewFriend : Effects Action
fetchNewFriend =
  Http.get decodeFriends "https://randomuser.me/api/"
    |> Task.toMaybe
    |> Task.map NewFriend
    |> Effects.task


decodeFriends : Json.Decoder (List Model)
decodeFriends =
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


-- VIEW

view : Signal.Address Action -> Maybe Model -> Html
view actionDispatcher maybeModel =
  div
    [ class "app-container"]
    [ (renderFriendCard maybeModel)
    , button
        [ class "button", onClick actionDispatcher GetNewFriend ]
        [ text "Meet a New Friend" ]
    ]


renderFriendCard : Maybe Model -> Html
renderFriendCard maybeModel =
  case maybeModel of
    Just model ->
      div
        [ class "friend-card" ]
        [ div
          [ class "friend-card--info" ]
          [ h4 [ class "info--name" ] [ text (model.firstName ++ " " ++ model.lastName) ]
          , p [] [ text model.address.street ]
          , p [] [ text model.address.city ]
          , p [] [ text model.address.state ]
          , p [] [ text model.email ]
          ]
          , div
          [ class "friend-card--picture" ]
          [ img [ src model.photo ] [] ]
        ]

    Nothing ->
      text ""
