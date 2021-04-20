module UIBook.UI.ActionLog exposing (list, preview, previewEmpty)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)


item : Int -> String -> Html msg
item index label =
    div
        [ css
            [ displayFlex
            , alignItems baseline
            , padding2 (px 16) (px 20)
            , fontDefault
            ]
        ]
        [ span
            [ css
                [ display inlineBlock
                , Css.width (px 32)
                , fontSize (px 14)
                , color (hex "#a0a0a0")
                ]
            ]
            [ text <| String.fromInt (index + 1)
            ]
        , span [] [ text label ]
        ]


preview :
    { theme : String
    , lastActionIndex : Int
    , lastActionLabel : String
    , onClick : msg
    }
    -> Html msg
preview props =
    button
        [ css
            [ border zero
            , backgroundColor transparent
            , display block
            , Css.width (pct 100)
            , padding zero
            , margin zero
            , textAlign left
            , fontSize (rem 1)
            , cursor pointer
            , outlineColor (hex props.theme)
            ]
        , onClick props.onClick
        ]
        [ item props.lastActionIndex props.lastActionLabel
        ]


previewEmpty : Html msg
previewEmpty =
    div
        [ css
            [ fontDefault
            , fontSize (px 14)
            , color (hex "#ccc")
            ]
        ]
        [ text "Your logged actions will appear here." ]


list :
    { theme : String
    , actions : List String
    }
    -> Html msg
list props =
    let
        docHeaderSize =
            34
    in
    div
        [ css [ paddingTop (px docHeaderSize) ] ]
        [ p
            [ css
                [ displayFlex
                , alignItems center
                , position absolute
                , top zero
                , left zero
                , right zero
                , Css.height (px docHeaderSize)
                , boxSizing borderBox
                , margin zero
                , padding2 zero (px 20)
                , backgroundColor (hex props.theme)
                , color (hex "#fff")
                , fontLabel
                , fontSize (px 12)
                , fontWeight bold
                ]
            ]
            [ text "Action log" ]
        , ul
            [ css
                [ listStyle none
                , padding zero
                , margin zero
                , Css.width (px 640)
                , maxWidth (pct 100)
                , maxHeight (vh 70)
                , overflowY auto
                ]
            ]
            (List.indexedMap item props.actions
                |> List.reverse
                |> List.map
                    (\item_ ->
                        li
                            [ css
                                [ borderTop3 (px 1) solid (hex "#f5f5f5")
                                ]
                            ]
                            [ item_ ]
                    )
            )
        ]
