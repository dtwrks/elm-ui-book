module Main exposing (main)

import UIDocs exposing (UIDocs, uiDocs, withDocs)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    uiDocs "HTML"
        |> withDocs
            [ buttonDocs
            , inputDocs
            ]
