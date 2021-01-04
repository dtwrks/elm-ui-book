module UIDocs.Widgets exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)



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
        , main_ [] props.main_
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


navList :
    { active : Maybe String
    , items : List String
    }
    -> Html msg
navList props =
    let
        item : String -> Html msg
        item label =
            li []
                [ a
                    [ href label
                    , css
                        [ displayFlex
                        , padding2 (px 12) (px 20)
                        , fontDefault
                        , hover
                            [ backgroundColor (hex "dadada")
                            ]
                        ]
                    ]
                    [ text label ]
                ]

        list : List String -> Html msg
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
