module UIBook.Widgets exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Widgets.Helpers exposing (..)
import Url.Builder



-- Search


searchInput :
    { theme : String
    , value : String
    , onInput : String -> msg
    , onFocus : msg
    , onBlur : msg
    }
    -> Html msg
searchInput props =
    div
        []
        [ input
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
        ]



-- NavList


navListItemStyles : Maybe String -> Maybe String -> String -> Style
navListItemStyles active preSelected slug =
    let
        base =
            [ displayFlex
            , padding2 (px 12) (px 20)
            , fontDefault
            , textDecoration none
            ]

        state =
            if preSelected == Just slug && active == Just slug then
                [ color (rgba 255 255 255 0.9)
                , backgroundColor (rgba 255 255 255 0.1)
                ]

            else if preSelected == Just slug then
                [ color (rgba 0 0 0 0.9)
                , backgroundColor (rgba 255 255 255 0.95)
                , hover [ backgroundColor (rgba 255 255 255 0.9) ]
                , focus [ backgroundColor (rgba 255 255 255 0.85), outline none ]
                ]

            else if active == Just slug then
                [ backgroundColor transparent
                , color (rgba 255 255 255 0.9)
                , focus [ color (rgba 255 255 255 1), outline none ]
                , Css.active [ color (rgba 255 255 255 0.8) ]
                ]

            else
                [ color (rgba 0 0 0 0.9)
                , backgroundColor (hex "#fff")
                , hover [ backgroundColor (rgba 255 255 255 0.95) ]
                , focus [ backgroundColor (rgba 255 255 255 0.85), outline none ]
                ]
    in
    Css.batch <| List.concat [ base, state ]


navList :
    { theme : String
    , preffix : String
    , active : Maybe String
    , preSelected : Maybe String
    , items : List ( String, String )
    }
    -> Html msg
navList props =
    let
        item : ( String, String ) -> Html msg
        item ( slug, label ) =
            li []
                [ a
                    [ href (Url.Builder.absolute [ props.preffix, slug ] [])
                    , css [ navListItemStyles props.active props.preSelected slug ]
                    ]
                    [ text label ]
                ]

        list : List ( String, String ) -> Html msg
        list items =
            if List.isEmpty items then
                p
                    [ css
                        [ backgroundColor (hex "#fff")
                        , color (hex "#ababab")
                        , margin zero
                        , padding2 (px 12) (px 20)
                        , fontDefault
                        ]
                    ]
                    [ text "No docs found" ]

            else
                ul
                    [ css
                        [ listStyle none
                        , padding zero
                        , margin zero
                        ]
                    ]
                <|
                    List.map item props.items
    in
    nav
        [ css
            [ backgroundColor (hex props.theme) ]
        ]
        [ list props.items ]



-- Trademark


trademark : Html msg
trademark =
    p
        [ css
            [ fontDefault
            , fontSize (px 10)
            , color (hex "#bababa")
            , margin zero
            , textTransform uppercase
            , letterSpacing (px 0.5)
            ]
        ]
        [ text "❤ Made by DTWRKS" ]



-- Action Log


actionLogItem : Int -> String -> Html msg
actionLogItem index label =
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
            [ text <| String.fromInt index
            ]
        , span [] [ text label ]
        ]


actionLog :
    { theme : String
    , numberOfActions : Int
    , lastAction : String
    , onClick : msg
    }
    -> Html msg
actionLog props =
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
        [ actionLogItem props.numberOfActions props.lastAction
        ]



-- ActionLogModal


actionLogModal : String -> List String -> Html msg
actionLogModal theme actions =
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
                , backgroundColor (hex theme)
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
            (List.indexedMap actionLogItem actions
                |> List.reverse
                |> List.map
                    (\item ->
                        li
                            [ css
                                [ borderTop3 (px 1) solid (hex "#f5f5f5")
                                ]
                            ]
                            [ item ]
                    )
            )
        ]



-- Docs


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


docsVariantWrapper : Html.Html msg -> Html msg
docsVariantWrapper html =
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
                , hover
                    [ borderColor (hex "#eaeaea")
                    ]
                ]
            ]
            [ Html.Styled.fromUnstyled html ]
        ]


docs : Html.Html msg -> Html msg
docs html =
    docsWrapper <|
        docsVariantWrapper html


docsWithVariants : List ( String, Html.Html msg ) -> Html msg
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
                (\( label_, html ) ->
                    li [ css [ paddingBottom (px 4) ] ]
                        [ docsVariantLabel label_
                        , docsVariantWrapper html
                        ]
                )
                variants
        )



-- Buttons


buttonStyles : Style
buttonStyles =
    batch
        [ display inlineFlex
        , alignItems center
        , padding2 (px 2) (px 4)
        , Css.disabled
            [ opacity (num 0.5)
            ]
        ]


button_ :
    { label : String
    , disabled : Bool
    , onClick : msg
    }
    -> Html msg
button_ props =
    button
        [ css [ buttonStyles ]
        , Attr.disabled props.disabled
        , onClick props.onClick
        ]
        [ text props.label ]


buttonLink :
    { label : String
    , disabled : Bool
    , href : String
    }
    -> Html msg
buttonLink props =
    a
        [ css [ buttonStyles ]
        , Attr.disabled props.disabled
        , href props.href
        ]
        [ text props.label ]
