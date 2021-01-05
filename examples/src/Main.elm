module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIDocs exposing (UIDocs, generateCustom)
import UIDocs.Theme exposing (defaultTheme)
import Widgets exposing (actionLogDocs, buttonDocs)


main : UIDocs
main =
    generateCustom
        { toHtml = toUnstyled
        , theme = defaultTheme
        , docs =
            [ buttonDocs
            , actionLogDocs
            ]
        }
