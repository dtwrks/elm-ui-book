module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIDocs exposing (UIDocs, uiDocs, withChapters, withRenderer)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    uiDocs "With Elm-CSS"
        |> withRenderer toUnstyled
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]
