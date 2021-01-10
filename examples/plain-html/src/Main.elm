module Main exposing (main)

import UIDocs exposing (UIDocs, generate)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    generate "With plain Html"
        [ buttonDocs
        , inputDocs
        ]
