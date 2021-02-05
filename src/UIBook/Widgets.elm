module UIBook.Widgets exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Theme exposing (Theme)
import Url.Builder



-- Constants


headerSize : Float
headerSize =
    140


footerSize : Float
footerSize =
    48


sidebarSizeOpen : Float
sidebarSizeOpen =
    280


sidebarSizeClosed : Float
sidebarSizeClosed =
    40


docHeaderSize : Float
docHeaderSize =
    34


actionPreviewSize : Float
actionPreviewSize =
    48


sidebarZ : Int
sidebarZ =
    1


headerAndFooterZ : Int
headerAndFooterZ =
    10



-- Typography


fontDefault : Style
fontDefault =
    fontFamily sansSerif


fontLabel : Style
fontLabel =
    Css.batch
        [ fontDefault
        , textTransform uppercase
        , letterSpacing (px 0.5)
        ]



-- Shadows


shadows : Style
shadows =
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.05)


shadowsLight : Style
shadowsLight =
    boxShadow4 (px 0) (px 1) (px 4) (rgba 0 0 0 0.1)


shadowsInset : Style
shadowsInset =
    boxShadow5 inset (px 0) (px 0) (px 20) (rgba 0 0 0 0.05)



-- Main Wrapper


{-| The main wrapper that layouts the scrollable sidebar with fixed header + main area content
-}
wrapper :
    { theme : Theme msg
    , title : Html msg
    , search : Html msg
    , sidebar : Html msg
    , chapterTitle : Maybe String
    , main_ : List (Html msg)
    , footer : Maybe (Html msg)
    , modal : Maybe (Html msg)
    , isMobile : Bool
    , isSidebarOpen : Bool
    , onCloseModal : msg
    }
    -> Html msg
wrapper props =
    let
        mainTopOffset =
            if props.isMobile then
                100

            else
                0

        sidebarSize =
            if props.chapterTitle == Nothing || props.isSidebarOpen || not props.isMobile then
                sidebarSizeOpen

            else
                sidebarSizeClosed
    in
    div
        [ css
            [ displayFlex
            , Css.height (vh 100)
            , overflowY auto
            , backgroundColor (hex "#fff")
            ]
        ]
        [ aside
            [ css
                [ position relative
                , zIndex (int sidebarZ)
                , Css.height (vh 100)
                , Css.width (px sidebarSize)
                , overflow auto
                , shadows
                ]
            ]
            [ div
                [ css
                    [ position fixed
                    , zIndex (int headerAndFooterZ)
                    , top (px 0)
                    , left (px 0)
                    , displayFlex
                    , flexDirection column
                    , justifyContent center
                    , Css.width (px sidebarSize)
                    , Css.height (px headerSize)
                    , boxSizing borderBox
                    , padding2 (px 16) (px 20)
                    , backgroundColor (hex "#fff")
                    , borderBottom3 (px 1) solid (hex "#f0f0f0")
                    ]
                ]
                [ props.title
                , div [ css [ paddingTop (px 16) ] ]
                    [ props.search ]
                ]
            , div
                [ css
                    [ position fixed
                    , top (px headerSize)
                    , left (px 0)
                    , bottom (px footerSize)
                    , Css.width (px sidebarSize)
                    , overflow auto
                    , displayFlex
                    , flexDirection column
                    ]
                ]
                [ props.sidebar
                , div
                    [ css
                        [ flexGrow (int 1)
                        , backgroundColor (hex "#fff")
                        ]
                    ]
                    []
                ]
            , div
                [ css
                    [ position fixed
                    , zIndex (int headerAndFooterZ)
                    , bottom (px 0)
                    , left (px 0)
                    , Css.width (px sidebarSize)
                    , Css.height (px footerSize)
                    , displayFlex
                    , alignItems center
                    , boxSizing borderBox
                    , padding2 zero (px 20)
                    , backgroundColor (hex "#fff")
                    , borderTop3 (px 1) solid (hex "#f0f0f0")
                    ]
                ]
                [ trademark ]
            ]
        , main_
            [ css
                [ Css.height (vh 100)
                , overflow auto
                , flexGrow (int 1)
                , padding zero
                ]
            ]
            [ div
                [ css
                    [ position fixed
                    , top (px mainTopOffset)
                    , left (px sidebarSize)
                    , right zero
                    , displayFlex
                    , alignItems center
                    , boxSizing borderBox
                    , padding2 zero (px 20)
                    , Css.height (px docHeaderSize)
                    , backgroundColor (hex props.theme.color)
                    , fontDefault
                    , fontSize (px 14)
                    , fontWeight bold
                    , color (hex "#fff")
                    ]
                ]
                [ props.chapterTitle
                    |> Maybe.withDefault ""
                    |> text
                ]
            , div
                [ css
                    [ position fixed
                    , top (px <| docHeaderSize + mainTopOffset)
                    , left (px sidebarSize)
                    , right zero
                    , bottom (px actionPreviewSize)
                    , backgroundColor (hex props.theme.color)
                    ]
                ]
                [ div
                    [ css
                        [ position relative
                        , Css.height (pct 100)
                        , overflow auto
                        , backgroundColor (rgba 240 240 240 0.97)
                        ]
                    ]
                    props.main_
                ]
            , div
                [ css
                    [ pointerEvents none
                    , zIndex (int sidebarZ)
                    , position fixed
                    , top (px <| docHeaderSize + mainTopOffset)
                    , left (px sidebarSize)
                    , right zero
                    , bottom (px actionPreviewSize)
                    , shadowsInset
                    ]
                ]
                []
            , div
                [ css
                    [ position fixed
                    , bottom zero
                    , left (px sidebarSize)
                    , right zero
                    , Css.height (px actionPreviewSize)
                    , boxSizing borderBox
                    , backgroundColor (hex "#fff")
                    , borderTop3 (px 1) solid (hex "#f0f0f0")
                    ]
                ]
                [ props.footer
                    |> Maybe.withDefault
                        (div
                            [ css
                                [ padding2 (px 16) (px 20)
                                , fontDefault
                                , fontSize (px 14)
                                , color (hex "#bababa")
                                ]
                            ]
                            [ text "Your actions will be logged here." ]
                        )
                ]
            ]
        , case props.modal of
            Just html ->
                div
                    [ css
                        [ position fixed
                        , bottom zero
                        , left zero
                        , right zero
                        , top zero
                        , displayFlex
                        , alignItems center
                        , justifyContent center
                        , zIndex (int 9999)
                        ]
                    ]
                    [ div
                        [ onClick props.onCloseModal
                        , css
                            [ position fixed
                            , bottom zero
                            , left zero
                            , right zero
                            , top zero
                            , zIndex (int 0)
                            , backgroundColor (rgba 0 0 0 0.1)
                            , cursor pointer
                            ]
                        ]
                        []
                    , div
                        [ css
                            [ position relative
                            , zIndex (int 1)
                            , margin (px 40)
                            , maxHeight (vh 80)
                            , overflowY auto
                            , backgroundColor (hex "#fff")
                            , borderRadius (px 8)
                            , shadows
                            ]
                        ]
                        [ html ]
                    ]

            Nothing ->
                text ""
        ]



-- Title


title :
    { theme : Theme msg
    , title : String
    , subtitle : String
    }
    -> Html msg
title props =
    a
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



-- Search


searchInput :
    { theme : Theme msg
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
                    , borderColor (hex props.theme.color)
                    ]
                ]
            ]
            []
        ]



-- NavList


navListItemStyles : Theme msg -> Maybe String -> Maybe String -> String -> Style
navListItemStyles _ active preSelected slug =
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
    { theme : Theme msg
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
                    , css [ navListItemStyles props.theme props.active props.preSelected slug ]
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
            [ backgroundColor (hex props.theme.color) ]
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
    { theme : Theme msg
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
            , outlineColor (hex props.theme.color)
            ]
        , onClick props.onClick
        ]
        [ actionLogItem props.numberOfActions props.lastAction
        ]



-- ActionLogModal


actionLogModal : Theme msg -> List String -> Html msg
actionLogModal theme actions =
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
                , backgroundColor (hex theme.color)
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
