module UIBook.UI.Search exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)


view :
    { theme : String
    , value : String
    , onInput : String -> msg
    , onFocus : msg
    , onBlur : msg
    }
    -> Html msg
view props =
    input
        [ id "ui-book-search"
        , value props.value
        , onInput props.onInput
        , onFocus props.onFocus
        , onBlur props.onBlur
        , placeholder "Type \"⌘K\" to search…"
        , css
            [ Css.width (pct 100)
            , padding (px 8)
            , border3 (px 3) solid transparent
            , borderRadius (px 4)
            , boxSizing borderBox
            , backgroundColor (hex "#f5f5f5")
            , fontDefault
            , fontSize (px 12)
            , hover
                [ backgroundColor (hex "#f0f0f0")
                ]
            , focus
                [ outline none
                , borderColor (hex props.theme)
                ]
            ]
        ]
        []
