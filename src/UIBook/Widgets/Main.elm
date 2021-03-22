module UIBook.Widgets.Main exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.Widgets.Helpers exposing (..)


type alias ChapterProps msg =
    { label : String
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
docsVariantWrapper backgroundColor_ html =
    div
        [ css
            [ padding (px 12)
            , borderRadius (px 4)
            , backgroundColor (hex "#fff")
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


docsVariantBackgroundColor : Maybe String -> Html msg
docsVariantBackgroundColor backgroundColor_ =
    div
        [ css
            [ backgroundColor (hex backgroundColor_)
            ]
        ]
        []


docs : Html.Html msg -> Html msg
docs html =
    docsWrapper <|
        docsVariantWrapper html


docsWithVariants : List ( { sectionLabel : String, sectionBackgroundColor : Maybe String }, Html.Html msg ) -> Html msg
docsWithVariants variants =
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
                (\( { sectionLabel, sectionBackgroundColor }, html ) ->
                    li [ css [ paddingBottom (px 4) ] ]
                        [ docsVariantLabel sectionLabel
                        , docsVariantWrapper html
                        ]
                )
                variants
        )
