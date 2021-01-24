module Main exposing (main)

import Element exposing (layout)
import UIBook exposing (UIBook, book, withChapters, withRenderer)
import Widgets exposing (buttonsChapter, inputChapter)


main : UIBook
main =
    book "Elm-UI"
        |> withRenderer (layout [])
        |> withChapters
            [ buttonsChapter
            , inputChapter
            ]
