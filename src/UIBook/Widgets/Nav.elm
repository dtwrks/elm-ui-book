module UIBook.Widgets.Nav exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Widgets.Helpers exposing (..)
import Url.Builder


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
    nav
        [ css
            [ backgroundColor (hex props.theme) ]
        ]
        [ list props.items ]
