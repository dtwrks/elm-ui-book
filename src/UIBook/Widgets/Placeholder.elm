module UIBook.Widgets.Placeholder exposing
    ( placeholder
    , custom, withBackgroundColor, withForegroundColor, withHeight, withWidth, view
    )

{-| An utility Widget that serves as a placeholder for the content of sections in your chapters

You can create a Placeholder for each one of your sections

    import UIBook.Widgets.Placeholder exposing (placeholder)

    card : Html msg -> Html msg
    card child = ...

    chapter "Card"
        |> withSection
            ( card placeholder )

@docs placeholder

You can also customize several aspects of the placeholder widget, including height, width, background color and foreground color.

    chapter "Placeholder"
        |> withSections
            [ ( "Custom"
              , Placeholder.custom
                    |> Placeholder.withWidth 400.0
                    |> Placeholder.withForegroundColor "#FFFFFF"
                    |> Placeholder.view
              )
            ]

@docs custom, withBackgroundColor, withForegroundColor, withHeight, withWidth, view

-}

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook.Widgets.Header exposing (view)
import UIBook.Widgets.Helpers exposing (themeColor)


type Props
    = Props { width : Maybe Float, height : Float, backgroundColor : String, foregroundColor : String }


{-| A placeholder can substitute any content in a chapter section
-}
placeholder : Html msg
placeholder =
    view custom


{-| Builds a placeholder view with or without customized aspects
-}
view : Props -> Html msg
view (Props props) =
    let
        width_ =
            case props.width of
                Just width__ ->
                    Css.width (px width__)

                Nothing ->
                    Css.width auto
    in
    div
        [ css
            [ opacity (Css.num 0.3)
            , Css.height (px props.height)
            , width_
            , backgroundSize2 (px 8) (px 8)
            , Css.property "background-color" props.foregroundColor
            , Css.property "background-image" <|
                "repeating-linear-gradient(45deg, "
                    ++ props.foregroundColor
                    ++ " 0, "
                    ++ props.foregroundColor
                    ++ " 1px,"
                    ++ props.backgroundColor
                    ++ " 0,"
                    ++ props.backgroundColor
                    ++ " 50%)"
            ]
        ]
        []


{-| Contains all the customs properties of the placeholder
-}
custom : Props
custom =
    Props { width = Nothing, height = 40, backgroundColor = "#ffffff", foregroundColor = themeColor }


{-| Sets a custom height for the placeholder
-}
withHeight : Float -> Props -> Props
withHeight height (Props props) =
    Props { props | height = height }


{-| Sets a custom width for the placeholder
-}
withWidth : Float -> Props -> Props
withWidth width (Props props) =
    Props { props | width = Just width }


{-| Sets a custom background color for the placeholder
-}
withBackgroundColor : String -> Props -> Props
withBackgroundColor color (Props props) =
    Props { props | backgroundColor = color }


{-| Sets a custom foreground color for the placeholder
-}
withForegroundColor : String -> Props -> Props
withForegroundColor color (Props props) =
    Props { props | foregroundColor = color }
