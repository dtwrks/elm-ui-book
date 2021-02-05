module UIBook.Widgets.Footer exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.Widgets.Helpers exposing (..)
import UIBook.Widgets.Icons exposing (..)


view : Html msg
view =
    p
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent spaceBetween
            , Css.width (pct 100)
            , fontDefault
            , fontSize (px 10)
            , fontWeight bold
            , margin zero
            , textTransform uppercase
            , opacity (num 0.3)
            , letterSpacing (px 0.5)
            ]
        ]
        [ iconGithub { size = 16, color = "#fff" }
        , div [ css [ paddingLeft (px 8) ] ] [ text "v1.0.1" ]
        ]
