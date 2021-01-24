module UIBook.Widgets exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Theme exposing (Theme)
import Url.Builder



-- Common


sidebarSize : Float
sidebarSize =
    280


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


shadows : Style
shadows =
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.05)


shadowsLight : Style
shadowsLight =
    boxShadow4 (px 0) (px 1) (px 4) (rgba 0 0 0 0.1)



-- Main Wrapper


{-| The main wrapper that layouts the scrollable sidebar with fixed header + main area content
-}
wrapper :
    { theme : Theme msg
    , sidebar : Html msg
    , main_ : List (Html msg)
    , bottom : Maybe (Html msg)
    , modal : Maybe (Html msg)
    , onCloseModal : msg
    }
    -> Html msg
wrapper props =
    div
        [ css
            [ displayFlex
            , Css.height (vh 100)
            , overflowY auto
            , backgroundColor (hex props.theme.color)
            ]
        ]
        [ aside
            [ css
                [ minHeight (pct 100)
                , Css.width (px sidebarSize)
                , position relative
                , zIndex (int 1)
                , shadows
                ]
            ]
            [ props.sidebar ]
        , main_ [ css [ flexGrow (int 1), padding zero ] ] props.main_
        , case props.bottom of
            Just html ->
                div
                    [ css
                        [ position absolute
                        , bottom (px 8)
                        , left (px <| sidebarSize + 20)
                        , right (px 16)
                        , zIndex (int 99)
                        , borderRadius (px 8)
                        , backgroundColor (hex "#fff")
                        , shadows
                        , fontDefault
                        ]
                    ]
                    [ html ]

            Nothing ->
                text ""
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



-- Sidebar


sidebar :
    { title : Html msg
    , search : Html msg
    , navList : Html msg
    }
    -> Html msg
sidebar props =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , Css.height (vh 100)
            ]
        ]
        [ a
            [ href "/"
            , css
                [ display block
                , textDecoration none
                , color (hex "#000")
                , padding2 (px 16) (px 20)
                , backgroundColor (hex "#fff")
                ]
            ]
            [ props.title ]
        , div
            [ css
                [ paddingBottom (px 16)
                , backgroundColor (hex "#fff")
                ]
            ]
            [ props.search
            ]
        , props.navList
        , div
            [ css
                [ flexGrow (int 1)
                , backgroundColor (hex "#fff")
                ]
            ]
            []
        , div
            [ css [ backgroundColor (hex "#fff") ]
            ]
            [ trademark ]
        ]



-- Title


title :
    { theme : Theme msg
    , title : String
    , subtitle : String
    }
    -> Html msg
title props =
    h1
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
        [ css
            [ padding3 zero (px 12) (px 16)
            ]
        ]
        [ input
            [ id "ui-docs-search"
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
    nav [] [ list props.items ]



-- Trademark


trademark : Html msg
trademark =
    p
        [ css
            [ fontDefault
            , fontSize (px 10)
            , color (hex "#bababa")
            , margin zero
            , padding (px 20)
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
            , alignItems center
            , padding (px 16)
            , fontDefault
            ]
        ]
        [ span
            [ css
                [ paddingRight (px 8)
                , fontSize (rem 0.9)
                , color (hex "#aaa")
                ]
            ]
            [ text <| "(" ++ String.fromInt index ++ ")"
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
    div []
        [ p
            [ css
                [ margin zero
                , padding2 (px 12) (px 20)
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


docsLabelBaseStyles : Theme msg -> Style
docsLabelBaseStyles _ =
    Css.batch
        [ margin zero
        , fontDefault
        ]


docsLabel : Theme msg -> String -> Html msg
docsLabel theme label_ =
    p
        [ css
            [ docsLabelBaseStyles theme
            , padding2 (px 8) (px 20)
            , backgroundColor (rgba 0 0 0 0.05)
            , color (hex "#fff")
            , fontSize (px 14)
            ]
        ]
        [ text label_ ]


docsWrapper : Theme msg -> String -> Html msg -> Html msg
docsWrapper theme label child =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , Css.height (vh 100)
            ]
        ]
        [ docsLabel theme label
        , div
            [ css
                [ flexGrow (int 1)
                , backgroundColor (rgba 240 240 240 0.97)
                , padding2 (px 16) (px 20)
                , borderBottom3 (px 1) solid (hex "#eaeaea")
                ]
            ]
            [ child ]
        ]


docsVariantLabel : Theme msg -> String -> Html msg
docsVariantLabel theme label_ =
    p
        [ css
            [ docsLabelBaseStyles theme
            , padding3 (px 16) (px 0) (px 8)
            , color (rgba 0 0 0 0.4)
            , fontLabel
            , fontSize (px 12)
            ]
        ]
        [ text label_ ]


docsVariantWrapper : Theme msg -> Html.Html msg -> Html msg
docsVariantWrapper _ html =
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


docsEmpty : Theme msg -> Html msg
docsEmpty theme =
    docsWrapper theme "" <|
        div [] [ text "" ]


docs : Theme msg -> String -> Html.Html msg -> Html msg
docs theme label html =
    docsWrapper theme label <|
        docsVariantWrapper theme html


docsWithVariants : Theme msg -> String -> List ( String, Html.Html msg ) -> Html msg
docsWithVariants theme label variants =
    docsWrapper theme label <|
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
                        [ docsVariantLabel theme label_
                        , docsVariantWrapper theme html
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
