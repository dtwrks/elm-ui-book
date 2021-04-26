module UIBook.UI.Nav exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)
import Url.Builder


navListItemStyles : Maybe String -> Maybe String -> String -> Style
navListItemStyles active preSelected slug =
    let
        baseStyles =
            [ displayFlex
            , padding2 (px 8) (px 20)
            , fontDefault
            , fontSize (px 14)
            , letterSpacing (px 1)
            , textDecoration none
            , Css.focus [ outline none ]
            , Css.active [ backgroundColor (rgba 255 255 255 0.05) ]
            ]

        activeStyles =
            if active == Just slug then
                [ color (rgba 255 255 255 1) ]

            else
                [ color (rgba 255 255 255 0.8) ]

        stateStyles =
            if preSelected == Just slug && active == Just slug then
                [ backgroundColor (rgba 255 255 255 0.25)
                ]

            else if preSelected == Just slug then
                [ backgroundColor (rgba 255 255 255 0.1)
                , hover [ backgroundColor (rgba 255 255 255 0.15) ]
                , focus [ backgroundColor (rgba 255 255 255 0.15) ]
                ]

            else if active == Just slug then
                [ backgroundColor (rgba 255 255 255 0.2)
                , hover [ backgroundColor (rgba 255 255 255 0.25) ]
                , focus [ backgroundColor (rgba 255 255 255 0.25) ]
                ]

            else
                [ hover [ backgroundColor (rgba 255 255 255 0.1) ]
                , focus [ backgroundColor (rgba 255 255 255 0.1) ]
                ]
    in
    Css.batch <| List.concat [ stateStyles, baseStyles, activeStyles ]


view :
    { theme : String
    , preffix : String
    , active : Maybe String
    , preSelected : Maybe String
    , items : List ( String, String )
    }
    -> Html msg
view props =
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
    nav []
        [ list props.items ]
