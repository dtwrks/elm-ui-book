module UIBook.UI.Markdown exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import SyntaxHighlight
import UIBook.UI.Helpers exposing (fontDefault, shadows, shadowsDark)


view : String -> Html msg
view =
    Markdown.Parser.parse
        >> Result.withDefault []
        >> Markdown.Renderer.render renderer
        >> Result.withDefault []
        >> (\content ->
                article
                    [ css
                        [ Css.width (px 640)
                        , maxWidth (pct 100)
                        , fontDefault
                        , fontSize (px 16)
                        , lineHeight (Css.em 1.4)
                        ]
                    ]
                    [ div [] content
                    , SyntaxHighlight.useTheme SyntaxHighlight.oneDark
                        |> Html.fromUnstyled
                    ]
           )


defaultPaddings : Style
defaultPaddings =
    Css.batch
        [ margin zero
        , padding zero
        , paddingBottom (px 24)
        ]



-- codeBlock =


renderer : Markdown.Renderer.Renderer (Html msg)
renderer =
    { heading =
        \{ level, children } ->
            case level of
                Block.H1 ->
                    Html.h1 [ css [ defaultPaddings ] ] children

                Block.H2 ->
                    Html.h2 [ css [ defaultPaddings ] ] children

                Block.H3 ->
                    Html.h3 [ css [ defaultPaddings ] ] children

                Block.H4 ->
                    Html.h4 [ css [ defaultPaddings ] ] children

                Block.H5 ->
                    Html.h5 [ css [ defaultPaddings ] ] children

                Block.H6 ->
                    Html.h6 [ css [ defaultPaddings ] ] children
    , paragraph = Html.p [ css [ defaultPaddings, color (hex "#666") ] ]
    , hardLineBreak = Html.br [ css [ defaultPaddings ] ] []
    , blockQuote =
        Html.blockquote
            [ css
                [ fontStyle italic
                , margin zero
                , marginBottom (px 24)
                , padding (px 24)
                , paddingBottom zero
                , borderLeft3 (px 4) solid (hex "#f0f0f0")
                ]
            ]
    , strong =
        \children -> Html.strong [] children
    , emphasis =
        \children -> Html.em [] children
    , strikethrough =
        \children -> Html.span [] children
    , codeSpan =
        \content ->
            Html.code
                [ css
                    [ display inlineBlock
                    , borderRadius (px 2)
                    , padding2 zero (px 8)
                    , color (hex "#dadada")
                    , backgroundColor (hex "#282c34")
                    ]
                ]
                [ Html.text content ]
    , link =
        \link content ->
            case link.title of
                Just title ->
                    Html.a
                        [ Attr.href link.destination
                        , Attr.title title
                        ]
                        content

                Nothing ->
                    Html.a [ Attr.href link.destination ] content
    , image =
        \{ src, alt, title } ->
            Html.img
                [ Attr.src src
                , Attr.alt alt
                , case title of
                    Just title_ ->
                        Attr.title title_

                    Nothing ->
                        class ""
                , css
                    [ maxWidth (pct 100)
                    , defaultPaddings
                    ]
                ]
                []
    , text =
        Html.text
    , unorderedList =
        \items ->
            Html.ul [ css [ defaultPaddings, paddingLeft (px 32) ] ]
                (items
                    |> List.map
                        (\item ->
                            case item of
                                Block.ListItem task children ->
                                    let
                                        checkbox =
                                            case task of
                                                Block.NoTask ->
                                                    Html.text ""

                                                Block.IncompleteTask ->
                                                    Html.input
                                                        [ Attr.disabled True
                                                        , Attr.checked False
                                                        , Attr.type_ "checkbox"
                                                        ]
                                                        []

                                                Block.CompletedTask ->
                                                    Html.input
                                                        [ Attr.disabled True
                                                        , Attr.checked True
                                                        , Attr.type_ "checkbox"
                                                        ]
                                                        []
                                    in
                                    Html.li [ css [ defaultPaddings ] ] (checkbox :: children)
                        )
                )
    , orderedList =
        \startingIndex items ->
            Html.ol
                (case startingIndex of
                    1 ->
                        [ Attr.start startingIndex, css [ defaultPaddings, paddingLeft (px 32) ] ]

                    _ ->
                        [ css [ defaultPaddings ] ]
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.li [ css [ defaultPaddings ] ]
                                itemBlocks
                        )
                )
    , html = Markdown.Html.oneOf []
    , codeBlock =
        \{ body, language } ->
            let
                wrapperStyles =
                    Css.batch
                        [ margin zero
                        , marginBottom (px 24)
                        , fontFamily monospace
                        , fontSize (px 16)
                        , padding2 (px 16) (px 24)
                        , backgroundColor (hex "#282c34")
                        , borderRadius (px 6)
                        , border3 (px 4) solid (hex "#dadada")
                        , shadowsDark
                        ]

                hCode =
                    case Maybe.withDefault "elm" language of
                        "elm" ->
                            SyntaxHighlight.elm body

                        "js" ->
                            SyntaxHighlight.javascript body

                        "json" ->
                            SyntaxHighlight.json body

                        "css" ->
                            SyntaxHighlight.css body

                        _ ->
                            SyntaxHighlight.noLang body
            in
            hCode
                |> Result.map (SyntaxHighlight.toBlockHtml Nothing)
                |> Result.map Html.fromUnstyled
                |> Result.map (\content -> div [ css [ defaultPaddings, wrapperStyles ] ] [ content ])
                |> Result.withDefault
                    (Html.pre [ css [ defaultPaddings, wrapperStyles ] ]
                        [ code []
                            [ text body
                            ]
                        ]
                    )
    , thematicBreak =
        Html.hr
            [ css
                [ margin zero
                , padding zero
                , marginBottom (px 24)
                , border zero
                , Css.height (px 2)
                , backgroundColor (hex "#f0f0f0")
                ]
            ]
            []
    , table =
        Html.table
            [ css
                [ defaultPaddings
                , maxWidth (pct 100)
                , overflowX auto
                , border3 (px 2) solid (hex "#f0f0f0")
                ]
            ]
    , tableHeader = Html.thead [ css [ border3 (px 2) solid (hex "#f0f0f0") ] ]
    , tableBody = Html.tbody [ css [ border3 (px 2) solid (hex "#f0f0f0") ] ]
    , tableRow = Html.tr [ css [ border3 (px 2) solid (hex "#f0f0f0") ] ]
    , tableHeaderCell =
        \maybeAlignment ->
            let
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map Attr.align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            Html.th (List.concat [ attrs, [ css [ border3 (px 2) solid (hex "#f0f0f0"), padding (px 8) ] ] ])
    , tableCell = \_ children_ -> Html.td [ css [ border3 (px 2) solid (hex "#f0f0f0"), padding (px 8) ] ] children_
    }
