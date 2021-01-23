module Main exposing (main)

import UIDocs exposing (UIDocs, uiDocs, withChapters)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    uiDocs "HTML"
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]
