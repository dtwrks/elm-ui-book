module UIBook.UI.Chapter exposing (ChapterLayout(..), view)

import Css exposing (..)
import Html as Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.Msg exposing (Msg(..))
import UIBook.UI.Helpers exposing (..)
import UIBook.UI.Markdown


type ChapterLayout
    = SingleColumn
    | TwoColumns


type alias Props state =
    { title : String
    , layout : ChapterLayout
    , description : Maybe String
    , backgroundColor : Maybe String
    , sections : List ( String, Html.Html (Msg state) )
    }


view : Props state -> Html (Msg state)
view props =
    let
        twoColumns : List Style -> Style
        twoColumns styles =
            if props.layout == TwoColumns then
                desktop styles

            else
                Css.batch []
    in
    article
        [ css
            [ insetZero
            , displayFlex
            , flexDirection column
            ]
        ]
        [ div
            [ css
                [ padding (px 16)
                , borderBottom3 (px 1) solid (hex "#eaeaea")
                ]
            ]
            [ title props.title
            ]
        , div
            [ css
                [ flexGrow (num 1)
                , scrollParent
                ]
            ]
            [ div
                [ css
                    [ scrollContent
                    , twoColumns
                        [ displayFlex
                        , alignItems stretch
                        ]
                    ]
                ]
                [ props.description
                    |> Maybe.map
                        (\description_ ->
                            div
                                [ css
                                    [ twoColumns
                                        [ Css.width (px 640)
                                        , maxWidth (pct 50)
                                        , scrollParent
                                        ]
                                    ]
                                ]
                                [ div
                                    [ css
                                        [ padding3 (px 22) (px 20) zero
                                        , twoColumns
                                            [ scrollContent ]
                                        ]
                                    ]
                                    [ UIBook.UI.Markdown.view description_
                                    ]
                                ]
                        )
                    |> Maybe.withDefault (text "")
                , div
                    [ css
                        [ twoColumns
                            [ flexGrow (num 1)
                            , scrollParent
                            ]
                        ]
                    ]
                    [ div
                        [ css
                            [ padding2 (px 24) (px 20)
                            , twoColumns
                                [ scrollContent
                                ]
                            ]
                        ]
                        [ sections props
                        ]
                    ]
                ]
            ]
        ]



-- Helpers


title : String -> Html msg
title title_ =
    h1
        [ css
            [ margin zero
            , padding zero
            , fontDefault
            , fontSize (px 20)
            , color (hex "#333")
            ]
        ]
        [ text title_ ]


sections : Props state -> Html (Msg state)
sections props =
    ul
        [ css
            [ flexGrow (num 1)
            , listStyleType none
            , padding zero
            , margin zero
            ]
        ]
        (List.map
            (\( label, html ) ->
                li
                    [ css
                        [ display block
                        , paddingBottom (px 24)
                        ]
                    ]
                    [ if label == "" then
                        text ""

                      else
                        p
                            [ css
                                [ margin zero
                                , padding zero
                                , paddingBottom (px 12)
                                , fontLabel
                                , color (hex "#999")
                                ]
                            ]
                            [ text label ]
                    , div
                        [ css
                            [ padding (px 12)
                            , borderRadius (px 4)
                            , shadowsLight
                            ]
                        , style "background"
                            (props.backgroundColor
                                |> Maybe.withDefault "#fff"
                            )
                        ]
                        [ div
                            [ css
                                [ border3 (px 1) dashed transparent
                                , position relative
                                , hover
                                    [ borderColor (hex "#eaeaea")
                                    ]
                                ]
                            ]
                            [ Html.Styled.fromUnstyled html ]
                        ]
                    ]
                    |> Html.Styled.map
                        (\msg ->
                            let
                                actionContext =
                                    props.title ++ " / " ++ label
                            in
                            case msg of
                                LogAction _ label_ ->
                                    LogAction actionContext label_

                                _ ->
                                    msg
                        )
            )
            props.sections
        )
