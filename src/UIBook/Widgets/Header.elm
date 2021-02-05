module UIBook.Widgets.Header exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Svg.Styled exposing (path, rect, svg)
import Svg.Styled.Attributes
import UIBook.Widgets.Helpers exposing (..)


view :
    { color : String
    , title : String
    , subtitle : String
    , custom : Maybe (Html msg)
    , isMenuOpen : Bool
    , isMenuButtonVisible : Bool
    , onClickMenuButton : msg
    }
    -> Html msg
view props =
    header
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent spaceBetween
            ]
        ]
        [ a
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
        , if props.isMenuButtonVisible then
            button
                [ onClick props.onClickMenuButton
                , css
                    [ fontDefault
                    , padding zero
                    , margin zero
                    , border zero
                    , boxShadow none
                    , backgroundColor transparent
                    , cursor pointer
                    , hover [ opacity (num 0.6) ]
                    , active [ opacity (num 0.4) ]
                    ]
                ]
                [ if props.isMenuOpen then
                    closeIcon

                  else
                    menuIcon
                ]

          else
            text ""
        ]


menuIcon : Html msg
menuIcon =
    svg
        [ Svg.Styled.Attributes.width "20"
        , Svg.Styled.Attributes.height "20"
        , Svg.Styled.Attributes.viewBox "0 0 512 512"
        ]
        [ path [ Svg.Styled.Attributes.d "M176.792 0H59.208C26.561 0 0 26.561 0 59.208v117.584C0 209.439 26.561 236 59.208 236h117.584C209.439 236 236 209.439 236 176.792V59.208C236 26.561 209.439 0 176.792 0zM196 176.792c0 10.591-8.617 19.208-19.208 19.208H59.208C48.617 196 40 187.383 40 176.792V59.208C40 48.617 48.617 40 59.208 40h117.584C187.383 40 196 48.617 196 59.208v117.584zM452 0H336c-33.084 0-60 26.916-60 60v116c0 33.084 26.916 60 60 60h116c33.084 0 60-26.916 60-60V60c0-33.084-26.916-60-60-60zm20 176c0 11.028-8.972 20-20 20H336c-11.028 0-20-8.972-20-20V60c0-11.028 8.972-20 20-20h116c11.028 0 20 8.972 20 20v116zM176.792 276H59.208C26.561 276 0 302.561 0 335.208v117.584C0 485.439 26.561 512 59.208 512h117.584C209.439 512 236 485.439 236 452.792V335.208C236 302.561 209.439 276 176.792 276zM196 452.792c0 10.591-8.617 19.208-19.208 19.208H59.208C48.617 472 40 463.383 40 452.792V335.208C40 324.617 48.617 316 59.208 316h117.584c10.591 0 19.208 8.617 19.208 19.208v117.584zM452 276H336c-33.084 0-60 26.916-60 60v116c0 33.084 26.916 60 60 60h116c33.084 0 60-26.916 60-60V336c0-33.084-26.916-60-60-60zm20 176c0 11.028-8.972 20-20 20H336c-11.028 0-20-8.972-20-20V336c0-11.028 8.972-20 20-20h116c11.028 0 20 8.972 20 20v116z" ] []
        ]


closeIcon : Html msg
closeIcon =
    svg
        [ Svg.Styled.Attributes.width "20"
        , Svg.Styled.Attributes.height "20"
        , Svg.Styled.Attributes.viewBox "0 0 512 512"
        ]
        [ path [ Svg.Styled.Attributes.d "M451.792 0H59.208C26.561 0 0 26.561 0 59.208v393.084C0 484.939 26.561 511.5 59.208 511.5h392.584c32.647 0 59.208-26.561 59.208-59.208V59.208C511 26.561 484.439 0 451.792 0zM471 452.292c0 10.591-8.617 19.208-19.208 19.208H59.208C48.617 471.5 40 462.883 40 452.292V59.208C40 48.617 48.617 40 59.208 40h392.584C462.383 40 471 48.617 471 59.208v393.084z" ] []
        , rect
            [ Svg.Styled.Attributes.x "105"
            , Svg.Styled.Attributes.y "377.943"
            , Svg.Styled.Attributes.width "386"
            , Svg.Styled.Attributes.height "40"
            , Svg.Styled.Attributes.rx "20"
            , Svg.Styled.Attributes.transform "rotate(-45 105 377.943)"
            ]
            []
        , rect
            [ Svg.Styled.Attributes.x "133.284"
            , Svg.Styled.Attributes.y "105"
            , Svg.Styled.Attributes.width "386"
            , Svg.Styled.Attributes.height "40"
            , Svg.Styled.Attributes.rx "20"
            , Svg.Styled.Attributes.transform "rotate(45 133.284 105)"
            ]
            []
        ]
