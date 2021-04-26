module UIBook.UI.Search exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)


inlineStyle : String
inlineStyle =
    """
#ui-book-search {
    transition: 0.2s;
}
#ui-book-search::placeholder {
    color: rgba(255, 255, 255, 0.8);
}
"""


view :
    { theme : String
    , value : String
    , onInput : String -> msg
    , onFocus : msg
    , onBlur : msg
    }
    -> Html msg
view props =
    div [ css [ Css.width (pct 100) ] ]
        [ node "style" [] [ text inlineStyle ]
        , input
            [ id "ui-book-search"
            , value props.value
            , onInput props.onInput
            , onFocus props.onFocus
            , onBlur props.onBlur
            , placeholder "Type \"⌘K\" to search…"
            , css
                [ Css.width (pct 100)
                , margin zero
                , padding2 (px 8) (px 12)
                , border3 (px 3) solid transparent
                , borderRadius (px 4)
                , boxSizing borderBox
                , backgroundColor (rgba 255 255 255 0.2)
                , fontDefault
                , fontSize (px 12)
                , color (hex "#fff")
                , hover
                    [ backgroundColor (rgba 255 255 255 0.25)
                    , borderColor (rgba 255 255 255 0.5)
                    ]
                , focus
                    [ outline none
                    , borderColor (rgba 255 255 255 1)
                    ]
                ]
            ]
            []
        ]
