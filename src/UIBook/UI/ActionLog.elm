module UIBook.UI.ActionLog exposing (list, preview, previewEmpty)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)


item : Int -> ( String, String ) -> Html msg
item index ( context, label ) =
    div
        [ css
            [ displayFlex
            , alignItems center
            , padding2 zero (px 20)
            , Css.height (px 50)
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
        , div []
            [ div
                [ css
                    [ paddingBottom (px 2)
                    , fontSize (px 12)
                    , color (hex "#999")
                    , letterSpacing (px 0.5)
                    ]
                ]
                [ text context ]
            , div
                [ css
                    [ fontSize (px 14)
                    , fontWeight bold
                    , fontFamily monospace
                    ]
                ]
                [ text label ]
            ]
        ]


preview :
    { lastActionIndex : Int
    , lastAction : ( String, String )
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
            , outline none
            , hover [ opacity (num 0.9) ]
            , active [ opacity (num 0.8) ]
            ]
        , onClick props.onClick
        ]
        [ item props.lastActionIndex props.lastAction
        ]


previewEmpty : Html msg
previewEmpty =
    div
        [ css
            [ displayFlex
            , alignItems center
            , fontDefault
            , fontSize (px 14)
            , color (hex "#aaa")
            , padding2 zero (px 20)
            , Css.height (px 50)
            ]
        ]
        [ text "Your logged actions will appear here." ]


list : List ( String, String ) -> Html msg
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
                , fontLabel
                , fontWeight bold
                , color (hex "#fff")
                ]
            , style "background-color" themeBackground
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
            (List.indexedMap item props
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
