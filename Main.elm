import Effects exposing (Effects, Never)
import Task

import NewIdentity exposing (view, update)

import StartApp

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
