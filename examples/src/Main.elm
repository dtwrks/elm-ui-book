module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIDocs exposing (UIDocs, generateCustom)
import Widgets exposing (buttonDocs)


main : UIDocs
main =
    generateCustom
        { toHtml = toUnstyled
        , docs =
            [ buttonDocs
            ]
        }
