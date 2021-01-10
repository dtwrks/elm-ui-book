module Main exposing (main)

import Element exposing (layout)
import UIDocs exposing (UIDocs, generateCustom)
import UIDocs.Theme exposing (defaultTheme)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    generateCustom
        { toHtml = layout []
        , theme = defaultTheme "With Elm-UI"
        , docs =
            [ buttonDocs
            , inputDocs
            ]
        }
