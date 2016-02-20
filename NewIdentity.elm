module NewIdentity where

import Html exposing (..)
import Html.Attributes exposing (class, src)

type alias Address =
  { street: String
  , city: String
  , state: String
  , zip: String
  }


type alias Model =
  { firstName: String
  , lastName: String
  , adress: Address
  , email: String
  , photo: String
  }


main : Html
main =
    div
      [ class "app-container"]
      [ div
          [ class "identity-card" ]
          [ div
              [ class "identity-card--info" ]
              [ h4 [ class "info--name" ] [ text "John Doe" ]
              , p [] [ text "123 Street" ]
              , p [] [ text "Montreal" ]
              , p [] [ text "Quebec" ]
              , p [] [ text "H0H 0H0" ]
              , p [] [ text "john.doe@webhost.com" ]
              ]
          , div
              [ class "identity-card--picture" ]
              [ img [ src "https://randomuser.me/api/portraits/med/men/69.jpg" ] [] ]
          ]
      , button [ class "button" ] [ text "Get New Identity" ]
      ]
