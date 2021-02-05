module UIBook.Widgets.Footer exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.Widgets.Helpers exposing (..)


view : Html msg
view =
    p
        [ css
            [ fontDefault
            , fontSize (px 10)
            , color (hex "#bababa")
            , margin zero
            , textTransform uppercase
            , letterSpacing (px 0.5)
            ]
        ]
        [ text "❤ Made by DTWRKS" ]
