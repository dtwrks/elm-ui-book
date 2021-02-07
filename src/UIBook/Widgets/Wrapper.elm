module UIBook.Widgets.Wrapper exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook.Widgets.Helpers exposing (..)


headerSize : Float
headerSize =
    64


menuHeaderSize : Float
menuHeaderSize =
    64


menuFooterSize : Float
menuFooterSize =
    48


sidebarSize : Float
sidebarSize =
    280


footerSize : Float
footerSize =
    48


docHeaderSize : Float
docHeaderSize =
    34


actionPreviewSize : Float
actionPreviewSize =
    48


headerZ : Int
headerZ =
    10


menuZ : Int
menuZ =
    5


mainOverlayZ : Int
mainOverlayZ =
    1


modalZ : Int
modalZ =
    20


view :
    { color : String
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
    div [ css [ backgroundColor (hex "#fff") ] ]
        [ div
            [ css
                [ position absolute
                , zIndex (int headerZ)
                , top zero
                , left zero
                , displayFlex
                , flexDirection column
                , justifyContent center
                , Css.width (px sidebarSize)
                , Css.height (px headerSize)
                , boxSizing borderBox
                , padding2 (px 16) (px 20)
                , backgroundColor (hex "#fff")
                , mobile [ Css.width (pct 100) ]
                ]
            , if props.isMenuOpen then
                css []

              else
                css [ mobile [ shadows ] ]
            ]
            [ props.header ]
        , aside
            [ if props.isMenuOpen then
                css []

              else
                css [ mobile [ display none ] ]
            ]
            [ div
                [ css
                    [ position absolute
                    , zIndex (int menuZ)
                    , top zero
                    , left zero
                    , bottom zero
                    , Css.width (px sidebarSize)
                    , overflow auto
                    , shadows
                    , mobile
                        [ Css.width (pct 100)
                        ]
                    ]
                ]
                []
            , div
                [ css
                    [ position absolute
                    , zIndex (int menuZ)
                    , top (px headerSize)
                    , left zero
                    , displayFlex
                    , alignItems center
                    , Css.width (px sidebarSize)
                    , Css.height (px menuHeaderSize)
                    , boxSizing borderBox
                    , padding2 zero (px 20)
                    , backgroundColor (hex "#fff")
                    , mobile [ Css.width (pct 100) ]
                    ]
                ]
                [ props.menuHeader ]
            , div
                [ css
                    [ position absolute
                    , zIndex (int menuZ)
                    , top (px <| headerSize + menuHeaderSize)
                    , left zero
                    , bottom (px menuFooterSize)
                    , Css.width (px sidebarSize)
                    , overflow auto
                    , displayFlex
                    , flexDirection column
                    , mobile [ Css.width (pct 100) ]
                    , backgroundColor (hex "#fff")
                    ]
                ]
                [ props.menu
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
                    [ position absolute
                    , zIndex (int menuZ)
                    , bottom zero
                    , left zero
                    , Css.width (px sidebarSize)
                    , Css.height (px footerSize)
                    , displayFlex
                    , alignItems center
                    , boxSizing borderBox
                    , padding2 zero (px 20)
                    , backgroundColor (hex "#fff")
                    , borderTop3 (px 1) solid (hex "#f0f0f0")
                    , mobile [ Css.width (pct 100) ]
                    ]
                ]
                [ props.menuFooter ]
            ]
        , main_ []
            [ div
                [ css
                    [ position absolute
                    , top zero
                    , left (px sidebarSize)
                    , right zero
                    , displayFlex
                    , alignItems center
                    , boxSizing borderBox
                    , padding2 zero (px 20)
                    , Css.height (px docHeaderSize)
                    , backgroundColor (hex props.color)
                    , fontDefault
                    , fontSize (px 14)
                    , fontWeight bold
                    , color (hex "#fff")
                    , mobile [ top (px headerSize), left zero ]
                    ]
                ]
                [ props.mainHeader
                ]
            , div
                [ css
                    [ position absolute
                    , top (px <| docHeaderSize)
                    , left (px sidebarSize)
                    , right zero
                    , bottom (px actionPreviewSize)
                    , backgroundColor (hex props.color)
                    , mobile
                        [ top (px <| docHeaderSize + headerSize)
                        , left zero
                        ]
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
                    [ props.main ]
                ]
            , div
                [ css
                    [ pointerEvents none
                    , zIndex (int mainOverlayZ)
                    , position absolute
                    , top (px docHeaderSize)
                    , left (px sidebarSize)
                    , right zero
                    , bottom (px actionPreviewSize)
                    , shadowsInset
                    , mobile [ left zero ]
                    ]
                ]
                []
            , div
                [ css
                    [ position absolute
                    , bottom zero
                    , left (px sidebarSize)
                    , right zero
                    , displayFlex
                    , alignItems center
                    , Css.height (px actionPreviewSize)
                    , padding2 zero (px 20)
                    , boxSizing borderBox
                    , backgroundColor (hex "#fff")
                    , borderTop3 (px 1) solid (hex "#f0f0f0")
                    , mobile [ left zero ]
                    ]
                ]
                [ props.mainFooter ]
            ]
        , case props.modal of
            Just html ->
                div
                    [ css
                        [ position absolute
                        , bottom zero
                        , left zero
                        , right zero
                        , top zero
                        , displayFlex
                        , alignItems center
                        , justifyContent center
                        , zIndex (int modalZ)
                        ]
                    ]
                    [ div
                        [ onClick props.onCloseModal
                        , css
                            [ position absolute
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
