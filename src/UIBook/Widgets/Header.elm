module UIBook.Widgets.Header exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Svg.Styled exposing (path, svg)
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
        [ path [ Svg.Styled.Attributes.d "M284.286 256.002L506.143 34.144c7.811-7.811 7.811-20.475 0-28.285-7.811-7.81-20.475-7.811-28.285 0L256 227.717 34.143 5.859c-7.811-7.811-20.475-7.811-28.285 0-7.81 7.811-7.811 20.475 0 28.285l221.857 221.857L5.858 477.859c-7.811 7.811-7.811 20.475 0 28.285a19.938 19.938 0 0014.143 5.857 19.94 19.94 0 0014.143-5.857L256 284.287l221.857 221.857c3.905 3.905 9.024 5.857 14.143 5.857s10.237-1.952 14.143-5.857c7.811-7.811 7.811-20.475 0-28.285L284.286 256.002z" ] []
        ]
