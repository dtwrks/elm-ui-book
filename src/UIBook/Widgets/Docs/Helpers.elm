module UIBook.Widgets.Docs.Helpers exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


mockTheme : String
mockTheme =
    "#1293D8"


mockList : String -> Html msg
mockList color =
    let
        item =
            div
                [ css [ padding (px 8) ] ]
                [ div
                    [ css
                        [ Css.height (px 40)
                        , backgroundColor (rgba 255 255 255 0.2)
                        ]
                    ]
                    []
                ]

        items =
            List.repeat 40 item
    in
    ul
        [ css
            [ margin zero
            , padding zero
            , boxSizing borderBox
            , backgroundColor (hex color)
            ]
        ]
        items


mockBlock : Bool -> Html msg
mockBlock isLight =
    div
        [ css
            [ Css.height (px 20)
            , Css.width (pct 100)
            , if isLight then
                backgroundColor (rgba 255 255 255 0.2)

              else
                backgroundColor (rgba 0 0 0 0.07)
            ]
        ]
        []
