module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIBook exposing (UIBook, book, withChapters, withRenderer)
import Widgets exposing (buttonsChapter, inputChapter)


main : UIBook
main =
    book "With Elm-CSS"
        |> withRenderer toUnstyled
        |> withChapters
            [ buttonsChapter
            , inputChapter
            ]
