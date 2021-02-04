module Main exposing (main)

import UIBook exposing (UIBook, book, withChapters)
import Widgets exposing (buttonsChapter, inputChapter)


main : UIBook
main =
    book "HTML"
        |> withChapters
            [ buttonsChapter
            , inputChapter
            ]
