module Main exposing (main)

import Element exposing (layout)
import UIDocs exposing (UIDocs, uiDocs, withChapters, withRenderer)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    uiDocs "Elm-UI"
        |> withRenderer (layout [])
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]
