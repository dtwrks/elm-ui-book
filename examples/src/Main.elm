module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import Theme exposing (theme)
import UIDocs exposing (UIDocs, generateCustom)
import Widgets exposing (actionLogDocs, buttonDocs)


main : UIDocs
main =
    generateCustom
        { toHtml = toUnstyled
        , theme = theme
        , docs =
            [ buttonDocs
            , actionLogDocs
            ]
        }
