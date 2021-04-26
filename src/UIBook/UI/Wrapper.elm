module UIBook.UI.Wrapper exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.UI.Helpers exposing (..)



-- View


view :
    { color : String
    , globals : List (Html msg)
    , header : Html msg
    , main : Html msg
    , mainHeader : Html msg
    , mainFooter : Html msg
    , menu : Html msg
    , menuHeader : Html msg
    , menuFooter : Html msg
    , modal : Maybe (Html msg)
    , isMenuOpen : Bool
    , onCloseModal : msg
    }
    -> Html msg
view props =
    div [ setThemeColor props.color ]
        [ div [ css [ display none ] ] props.globals
        , div
            [ css
                [ insetZero
                , displayFlex
                , alignItems stretch
                , mobile
                    [ flexDirection column
                    ]
                ]
            , style "background-color" themeColor
            ]
            [ -- Sidebar
              div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , Css.width (px sidebarSize)
                    , mobile
                        [ Css.width (pct 100)
                        ]
                    ]
                , if props.isMenuOpen then
                    css [ mobile [ flexGrow (num 1) ] ]

                  else
                    css []
                ]
                [ -- Header
                  div
                    [ css [ padding (px 8) ]
                    ]
                    [ props.header ]
                , -- Menu
                  div
                    [ css
                        [ flexGrow (num 1)
                        , displayFlex
                        , flexDirection column
                        ]
                    , if props.isMenuOpen then
                        css [ mobile [ displayFlex ] ]

                      else
                        css [ mobile [ display none ] ]
                    ]
                    [ -- Menu Header
                      div
                        [ css
                            [ padding (px 8)
                            , borderBottom3 (px 1) solid (rgba 255 255 255 0.2)
                            ]
                        ]
                        [ props.menuHeader ]
                    , -- Menu Main
                      div
                        [ css
                            [ position relative
                            , flexGrow (num 1)
                            ]
                        ]
                        [ div
                            [ css
                                [ insetZero
                                , overflow auto
                                , padding2 (px 8) zero
                                ]
                            ]
                            [ props.menu
                            ]
                        ]
                    , -- Menu Footer
                      div
                        [ css
                            [ padding (px 8)
                            , borderTop3 (px 1) solid (rgba 255 255 255 0.2)
                            ]
                        ]
                        [ props.menuFooter ]
                    ]
                ]
            , -- Main
              div
                [ css
                    [ flexGrow (num 1)
                    , displayFlex
                    , flexDirection column
                    , padding4 (px 8) (px 8) zero zero
                    , mobile [ paddingLeft (px 8) ]
                    ]
                , if props.isMenuOpen then
                    css [ mobile [ display none ] ]

                  else
                    css [ mobile [ displayFlex ] ]
                ]
                [ div
                    [ css
                        [ flexGrow (num 1)
                        , displayFlex
                        , flexDirection column
                        , backgroundColor (hex "#fff")
                        , borderRadius4 (px 4) (px 4) zero zero
                        ]
                    ]
                    [ -- Main Header
                      div
                        [ css
                            [ padding (px 8)
                            , borderBottom3 (px 1) solid (rgba 0 0 0 0.1)
                            ]
                        ]
                        [ props.mainHeader ]
                    , -- Main Main
                      div
                        [ css
                            [ position relative
                            , flexGrow (num 1)
                            , padding2 (px 8) zero
                            ]
                        ]
                        [ div [ css [ insetZero, overflow auto ] ]
                            [ props.main ]
                        ]
                    , -- Main Footer
                      div
                        [ css
                            [ padding (px 8)
                            , borderTop3 (px 1) solid (rgba 0 0 0 0.1)
                            ]
                        ]
                        [ props.mainFooter ]
                    ]
                ]
            ]
        , case props.modal of
            Just html ->
                div
                    [ css
                        [ insetZero
                        , displayFlex
                        , alignItems center
                        , justifyContent center
                        , zIndex (int modalZ)
                        ]
                    ]
                    [ div
                        [ onClick props.onCloseModal
                        , css
                            [ insetZero
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
                            , maxHeight (calc (pct 100) minus (px 120))
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



-- Helpers


sidebarSize : Float
sidebarSize =
    280


modalZ : Int
modalZ =
    99999
