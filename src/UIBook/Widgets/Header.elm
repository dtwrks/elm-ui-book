module UIBook.Widgets.Header exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Widgets.Helpers exposing (..)
import UIBook.Widgets.Icons exposing (..)


view :
    { color : String
    , title : String
    , subtitle : String
    , custom : Maybe (Html msg)
    , isMenuOpen : Bool
    , onClickMenuButton : msg
    }
    -> Html msg
view props =
    header
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent spaceBetween
            ]
        ]
        [ a
            [ href "/"
            , css
                [ display block
                , textDecoration none
                , color (hex "#000")
                ]
            ]
            [ h1
                [ css
                    [ fontDefault
                    , fontWeight (int 600)
                    , fontSize (px 16)
                    , margin zero
                    , padding zero
                    ]
                ]
                [ span
                    [ css
                        [ display block
                        , paddingRight (px 4)
                        ]
                    ]
                    [ text props.title
                    ]
                , span
                    [ css
                        [ fontWeight (int 400)
                        , display block
                        ]
                    ]
                    [ text props.subtitle ]
                ]
            ]
        , button
            [ onClick props.onClickMenuButton
            , css
                [ display none
                , fontDefault
                , padding zero
                , margin zero
                , border zero
                , boxShadow none
                , backgroundColor transparent
                , cursor pointer
                , hover [ opacity (num 0.6) ]
                , active [ opacity (num 0.4) ]
                , mobile [ display block ]
                ]
            ]
            [ if props.isMenuOpen then
                iconClose

              else
                iconMenu
            ]
        ]
