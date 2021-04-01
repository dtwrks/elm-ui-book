module UIBook.Widgets.Placeholder exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


type alias PlaceholderProps =
    { custom : Maybe ( Int, Int )
    }


placeholder : Html msg
placeholder =
    div
        [ css
            [ backgroundColor (hex "#444CF7")
            , opacity (Css.num 0.3)
            , backgroundSize2 (px 8) (px 8)
            , Css.height (px 40)
            , Css.width auto
            , Css.property "background-image" "repeating-linear-gradient(45deg, #444cf7 0, #444cf7 1px, #ffffff 0, #ffffff 50%)"
            ]
        ]
        []
