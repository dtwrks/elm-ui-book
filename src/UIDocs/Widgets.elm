module UIDocs.Widgets exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import UIDocs.Theme exposing (Theme)
import Url.Builder



-- Common


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
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.1)


shadowsLight : Style
shadowsLight =
    boxShadow4 (px 0) (px 1) (px 4) (rgba 0 0 0 0.1)



-- Main Wrapper


{-| The main wrapper that layouts the scrollable sidebar with fixed header + main area content
-}
wrapper :
    { sidebar : List (Html msg)
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
            , Css.overflowY auto
            ]
        ]
        [ aside
            [ css
                [ borderRight3 (px 1) solid (hex "eaeaea")
                , minHeight (pct 100)
                , Css.width (px 240)
                , shadows
                ]
            ]
            props.sidebar
        , main_ [ css [ flexGrow (int 1), padding zero ] ] props.main_
        , case props.bottom of
            Just html ->
                div
                    [ css
                        [ position absolute
                        , bottom (px 8)
                        , left (px 248)
                        , right (px 8)
                        , zIndex (int 99)
                        , borderRadius (px 8)
                        , backgroundColor (hex "white")
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



-- Title


title :
    { title : String
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
            , padding2 (px 16) (px 20)
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


itemIsActive : Maybe String -> String -> Bool
itemIsActive active item =
    active
        |> Maybe.map (\id -> id == item)
        |> Maybe.withDefault False



-- Search


searchInput :
    { value : String
    , onInput : String -> msg
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
            , placeholder "Type \"/\" to search…"
            , css
                [ Css.width (pct 100)
                , padding (px 8)
                , border zero
                , backgroundColor (hex "#f5f5f5")
                , borderRadius (px 4)
                , boxSizing borderBox
                , focus
                    [ outlineColor (hex "#333")
                    ]
                ]
            ]
            []
        ]



-- NavList


navListItemStyles : Bool -> Style
navListItemStyles isActive =
    let
        base =
            [ displayFlex
            , padding2 (px 12) (px 20)
            , fontDefault
            , textDecoration none
            , color (hex "#333")
            ]

        state =
            if isActive then
                [ backgroundColor (hex "#333")
                , color (hex "#fafafa")
                ]

            else
                [ hover
                    [ backgroundColor (hex "dadada")
                    ]
                ]
    in
    Css.batch <| List.concat [ base, state ]


navList :
    { preffix : String
    , active : Maybe String
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
                    , css [ navListItemStyles (itemIsActive props.active slug) ]
                    ]
                    [ text label ]
                ]

        list : List ( String, String ) -> Html msg
        list items =
            if List.isEmpty items then
                p [ css [ padding2 (px 8) (px 20) ] ] [ text "No docs found." ]

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
    { numberOfActions : Int
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
            ]
        , onClick props.onClick
        ]
        [ actionLogItem props.numberOfActions props.lastAction
        ]



-- ActionLogModal


actionLogModal : List String -> Html msg
actionLogModal actions =
    div []
        [ p
            [ css
                [ margin zero
                , padding2 (px 12) (px 20)
                , backgroundColor (hex "#333")
                , color (hex "#f5f5f5")
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


docsLabelBaseStyles : Theme -> Style
docsLabelBaseStyles theme =
    Css.batch
        [ margin zero
        , fontDefault
        ]


docsLabel : Theme -> String -> Html msg
docsLabel theme label_ =
    p
        [ css
            [ docsLabelBaseStyles theme
            , padding2 (px 8) (px 16)
            , backgroundColor (hex theme.docsLabelBackground)
            , color (hex theme.docsLabelText)
            , fontSize (px 14)
            ]
        ]
        [ text label_ ]


docsVariantLabel : Theme -> String -> Html msg
docsVariantLabel theme label_ =
    p
        [ css
            [ docsLabelBaseStyles theme
            , padding3 (px 16) (px 16) (px 8)
            , backgroundColor (hex theme.docsVariantBackground)
            , color (hex theme.docsVariantText)
            , fontLabel
            , fontSize (px 12)
            ]
        ]
        [ text label_ ]


docsWrapper : Theme -> Html.Html msg -> Html msg
docsWrapper theme html =
    div
        [ css
            [ padding (px theme.docsPadding)
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


docs : Theme -> String -> Html.Html msg -> Html msg
docs theme label html =
    div []
        [ docsLabel theme label
        , div
            [ css
                [ backgroundColor (hex theme.docsVariantBackground)
                , padding2 (px 16) (px 20)
                , borderBottom3 (px 1) solid (hex "#eaeaea")
                ]
            ]
            [ docsWrapper theme html ]
        ]


docsWithVariants : Theme -> String -> List ( String, Html.Html msg ) -> Html msg
docsWithVariants theme label variants =
    div
        []
        [ docsLabel theme label
        , ul
            [ css
                [ listStyleType none
                , padding zero
                , margin zero
                , backgroundColor (hex theme.docsVariantBackground)
                , padding3 (px 4) (px 20) (px 16)
                , borderBottom3 (px 1) solid (hex "#eaeaea")
                ]
            ]
          <|
            List.map
                (\( label_, html ) ->
                    li [ css [ paddingBottom (px 4) ] ]
                        [ docsVariantLabel theme label_
                        , docsWrapper theme html
                        ]
                )
                variants
        ]



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
