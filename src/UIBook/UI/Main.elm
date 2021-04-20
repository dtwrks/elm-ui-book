module UIBook.UI.Main exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.UI.Helpers exposing (..)


type alias ChapterProps msg =
    { title : String
    , backgroundColor : Maybe String
    , sections : List ( String, Html.Html msg )
    }


docsLabelBaseStyles : Style
docsLabelBaseStyles =
    Css.batch
        [ margin zero
        , fontDefault
        ]


docsLabel : String -> Html msg
docsLabel label_ =
    p
        [ css
            [ docsLabelBaseStyles
            , padding2 (px 8) (px 20)
            , backgroundColor (rgba 0 0 0 0.05)
            , color (hex "#fff")
            , fontSize (px 14)
            ]
        ]
        [ text label_ ]


docsEmpty : Html msg
docsEmpty =
    text ""


docsWrapper : Html msg -> Html msg
docsWrapper child =
    div
        [ css
            [ padding2 (px 16) (px 20)
            ]
        ]
        [ child ]


docsVariantLabel : String -> Html msg
docsVariantLabel label_ =
    p
        [ css
            [ docsLabelBaseStyles
            , padding3 (px 16) (px 0) (px 8)
            , color (rgba 0 0 0 0.4)
            , fontLabel
            , fontSize (px 12)
            ]
        ]
        [ text label_ ]


docsVariantWrapper : Maybe String -> Html.Html msg -> Html msg
docsVariantWrapper maybeBackgroundColor html =
    let
        bgValue : Color
        bgValue =
            case maybeBackgroundColor of
                Just backgroundColor_ ->
                    hex backgroundColor_

                Nothing ->
                    hex "#fff"
    in
    div
        [ css
            [ padding (px 12)
            , borderRadius (px 4)
            , backgroundColor bgValue
            , shadowsLight
            ]
        ]
        [ div
            [ css
                [ border3 (px 1) dashed transparent
                , position relative
                , hover
                    [ borderColor (hex "#eaeaea")
                    ]
                ]
            ]
            [ Html.Styled.fromUnstyled html ]
        ]


docs : Maybe String -> Html.Html msg -> Html msg
docs backgroundColor html =
    docsWrapper <|
        docsVariantWrapper backgroundColor html


docsWithVariants : ChapterProps msg -> Html msg
docsWithVariants props =
    docsWrapper <|
        (ul
            [ css
                [ listStyleType none
                , padding zero
                , margin zero
                , marginTop (px -16)
                , borderBottom3 (px 1) solid (hex "#eaeaea")
                ]
            ]
         <|
            List.map
                (\( label, view ) ->
                    li [ css [ paddingBottom (px 4) ] ]
                        [ docsVariantLabel label
                        , docsVariantWrapper props.backgroundColor view
                        ]
                )
                props.sections
        )
