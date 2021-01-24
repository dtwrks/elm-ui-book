module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIBook exposing (UIBook, book, withChapters, withRenderer)
import Widgets exposing (buttonDocs, inputDocs)


main : UIBook
main =
    book "With Elm-CSS"
        |> withRenderer toUnstyled
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]
