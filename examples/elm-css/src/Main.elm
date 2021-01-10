module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIDocs exposing (UIDocs, generateCustom)
import UIDocs.Theme exposing (defaultTheme)
import Widgets exposing (buttonDocs, inputDocs)


main : UIDocs
main =
    generateCustom
        { toHtml = toUnstyled
        , theme = defaultTheme "With Elm-CSS"
        , docs =
            [ buttonDocs
            , inputDocs
            ]
        }
