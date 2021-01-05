module UIDocs.Widgets exposing (..)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import UIDocs.Theme exposing (Theme)



-- Common


fontDefault : Style
fontDefault =
    fontFamily sansSerif


shadows : Style
shadows =
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.1)



-- Main Wrapper


{-| The main wrapper that layouts the scrollable sidebar with fixed header + main area content
-}
wrapper :
    { sidebar : List (Html msg)
    , main_ : List (Html msg)
    , bottom : Maybe (Html msg)
    , modal : Maybe (Html msg)
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
                        , padding (px 16)
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
        ]


{-| The main docs title.
-}
title : String -> Html msg
title title_ =
    h1
        [ css
            [ fontDefault
            , fontWeight (int 600)
            , fontSize (px 16)
            , margin zero
            , padding2 (px 16) (px 20)
            ]
        ]
        [ text title_ ]


itemIsActive : Maybe String -> String -> Bool
itemIsActive active item =
    active
        |> Maybe.map (\id -> id == item)
        |> Maybe.withDefault False


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
    { active : Maybe String
    , items : List ( String, String )
    }
    -> Html msg
navList props =
    let
        item : ( String, String ) -> Html msg
        item ( slug, label ) =
            li []
                [ a
                    [ href slug
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


actionLog : Int -> String -> Html msg
actionLog length label_ =
    div [ css [ displayFlex, alignItems center ] ]
        [ span
            [ css
                [ paddingRight (px 8)
                , fontSize (rem 0.9)
                , color (hex "#aaa")
                ]
            ]
            [ text <| "(" ++ String.fromInt length ++ ")"
            ]
        , span [] [ text label_ ]
        ]



-- Docs


docsLabelBaseStyles : Theme -> Style
docsLabelBaseStyles theme =
    Css.batch
        [ margin zero
        , padding2 (px 8) (px 16)
        , fontDefault
        ]


docsLabel : Theme -> String -> Html msg
docsLabel theme label_ =
    p
        [ css
            [ docsLabelBaseStyles theme
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
            , backgroundColor (hex theme.docsVariantBackground)
            , color (hex theme.docsVariantText)
            , textTransform uppercase
            , fontSize (px 12)
            , fontWeight (int 500)
            , letterSpacing (px 0.5)
            ]
        ]
        [ text label_ ]


docsWrapper : Theme -> Html.Html msg -> Html msg
docsWrapper theme html =
    div
        [ css
            [ padding (px theme.docsPadding)
            ]
        ]
        [ Html.Styled.fromUnstyled html ]


docs : Theme -> String -> Html.Html msg -> Html msg
docs theme label html =
    div []
        [ docsLabel theme label
        , docsWrapper theme html
        ]


docsWithVariants : Theme -> String -> List ( String, Html.Html msg ) -> Html msg
docsWithVariants theme label variants =
    div []
        [ docsLabel theme label
        , ul
            [ css
                [ listStyleType none
                , padding zero
                , margin zero
                ]
            ]
          <|
            List.map
                (\( label_, html ) ->
                    li []
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
