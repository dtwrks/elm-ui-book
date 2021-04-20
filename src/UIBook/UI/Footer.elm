module UIBook.UI.Footer exposing (view)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.UI.Helpers exposing (..)
import UIBook.UI.Icons exposing (..)


view : Html msg
view =
    a
        [ href "https://package.elm-lang.org/packages/dtwrks/elm-ui-book/latest/"
        , Html.Styled.Attributes.target "_blank"
        , css
            [ displayFlex
            , alignItems center
            , Css.width (pct 100)
            , margin zero
            , textDecoration none
            , color (hex "#ccc")
            , transition [ Css.Transitions.color 400 ]
            , hover
                [ color (hex "#1293D8")
                ]
            ]
        ]
        [ iconElm { size = 16, color = "currentColor" }
        , div
            [ css
                [ paddingLeft (px 8)
                , fontDefault
                , fontSize (px 10)
                , textTransform uppercase
                , letterSpacing (px 0.5)
                ]
            ]
            [ text "dtwrks/elm-ui-docs" ]
        ]
